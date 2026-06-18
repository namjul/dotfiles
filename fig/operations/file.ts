import { dirname, extname, relative } from "@std/path";
import { Result } from "@gordonb/result";
import * as Option from "@gordonb/result/option";
import { $, fs } from "zx";
import { writeFile } from "atomically";
import toPath from "../path.ts";
import { root } from "../root.ts";
import { chmod } from "../posix/chmod.ts";
import { cp } from "../posix/cp.ts";
import { mkdir } from "../posix/mkdir.ts";
import { rm } from "../posix/rm.ts";
import type {
  FileDirectoryOptions,
  FileEncryptedOptions,
  FileError,
  FileOptions,
  FileResult,
  FileSourceOptions,
  FileState,
  FileWriteOptions,
} from "../types.ts";

function getExitCode(error: unknown): number {
  if (typeof error === "object" && error !== null && "exitCode" in error) {
    const value = Reflect.get(error, "exitCode");
    return typeof value === "number" ? value : 1;
  }
  return 1;
}

async function hasSops(): Promise<boolean> {
  const result = await $`command -v sops`.nothrow();
  return result.exitCode !== 0 ? false : true;
}

/**
 * File operation - atomic file management
 */
export async function file(options: FileOptions): Promise<FileResult> {
  const targetPath = toPath(options.path).resolve.toString();
  if (options.src) {
    options.src = toPath(options.src).resolve.toString();
  }
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  try {
    // Guard against a symlink (e.g. ~/.claude/skills → repo/skills) that would
    // cause us to write back into this repo's working copy. Walk up to the
    // first existing ancestor and bail if realpath resolves inside the repo.
    const targetDir = targetPath.split("/").slice(0, -1).join("/") || "/";
    let checkDir = targetDir;
    while (checkDir !== "/") {
      if (fs.pathExistsSync(checkDir)) {
        try {
          const resolved = Deno.realPathSync(checkDir);
          if (
            !checkDir.startsWith(root) &&
            !relative(root, resolved).startsWith("..")
          ) {
            return Result.err({ type: "SYMLINK_DETECTED", path: checkDir });
          }
        } catch { /* ignore resolution errors */ }
        break;
      }
      checkDir = dirname(checkDir);
    }

    // Ensure parent directory exists
    fs.ensureDirSync(targetDir);
  } catch (cause) {
    const errorType: FileError["type"] = sudo
      ? "PERMISSION_DENIED"
      : "WRITE_FAILED";
    if (errorType === "PERMISSION_DENIED") {
      return Result.err({
        type: errorType,
        path: targetPath,
        operation: options.state,
        cause,
      });
    }
    return Result.err({
      type: errorType,
      path: targetPath,
      cause,
    });
  }

  switch (options.state) {
    case "file":
      return await writeFileContent({ ...options, path: targetPath });
    case "link":
      return createSymlink({ ...options, path: targetPath });
    case "hardlink":
      return createHardlink({ ...options, path: targetPath });
    case "copy":
      return await copyFile({ ...options, path: targetPath });
    case "directory":
      return await ensureDirectory({ ...options, path: targetPath });
    case "encrypted":
      return await decryptEncrypted({ ...options, path: targetPath });
  }
}

/**
 * Write file contents atomically
 */
async function writeFileContent(
  options: FileWriteOptions,
): Promise<FileResult> {
  const { path, contents } = options;
  const mode = Option.from(options.mode);
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  // Check if target exists and force is not set
  if (
    fs.pathExistsSync(path) &&
    !Option.unwrapOr(Option.from(options.force), false)
  ) {
    return Result.err({
      type: "TARGET_EXISTS",
      path,
      operation: "file",
    });
  }

  try {
    if (sudo) {
      const tmp = `/tmp/fig-${Date.now()}-${
        Math.random().toString(36).slice(2)
      }`;
      fs.writeFileSync(tmp, contents);
      try {
        const cpErr = await cp(tmp, path, { sudo: true });
        if (cpErr) throw cpErr;
        if (Option.isSome(mode)) {
          const err = await chmod(mode, path, { sudo: true });
          if (err) throw err;
        }
      } finally {
        fs.removeSync(tmp);
      }
    } else {
      // Use atomically for non-sudo writes.
      const data: string | Buffer = typeof contents === "string"
        ? contents
        : Buffer.from(contents);
      if (Option.isSome(mode)) {
        await writeFile(path, data, { mode });
      } else {
        await writeFile(path, data);
      }
    }

    return Result.ok({ path });
  } catch (cause) {
    const errorType: FileError["type"] = sudo
      ? "PERMISSION_DENIED"
      : "WRITE_FAILED";
    if (errorType === "PERMISSION_DENIED") {
      return Result.err({
        type: errorType,
        path,
        operation: "file",
        cause,
      });
    } else {
      return Result.err({
        type: errorType,
        path,
        cause,
      });
    }
  }
}

function clearTarget(
  targetPath: string,
  operation: FileState,
  force: boolean,
): FileResult {
  try {
    try {
      fs.lstatSync(targetPath);
    } catch {
      return Result.ok({ path: targetPath });
    }

    if (!force) {
      return Result.err({
        type: "TARGET_EXISTS",
        path: targetPath,
        operation,
      });
    }

    fs.removeSync(targetPath);
    return Result.ok({ path: targetPath });
  } catch (cause) {
    return Result.err({
      type: "WRITE_FAILED",
      path: targetPath,
      cause,
    });
  }
}

/**
 * Ensure directory exists and mode is correct.
 */
async function ensureDirectory(
  options: FileDirectoryOptions,
): Promise<FileResult> {
  const { path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);
  const mode = Option.from(options.mode);
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  try {
    if (fs.pathExistsSync(targetPath)) {
      const stat = fs.lstatSync(targetPath);
      if (!stat.isDirectory()) {
        if (!force) {
          return Result.err({
            type: "TARGET_EXISTS",
            path: targetPath,
            operation: "directory",
          });
        }
        fs.removeSync(targetPath);
      }
    }

    if (sudo) {
      const mkdirErr = await mkdir(targetPath, { parents: true, sudo: true });
      if (mkdirErr) throw mkdirErr;
      if (Option.isSome(mode)) {
        const err = await chmod(mode, targetPath, { sudo: true });
        if (err) throw err;
      }
    } else {
      fs.ensureDirSync(targetPath);
      if (Option.isSome(mode)) {
        const err = await chmod(mode, targetPath);
        if (err) throw err;
      }
    }
    return Result.ok({ path: targetPath });
  } catch (cause) {
    const errorType: FileError["type"] = sudo
      ? "PERMISSION_DENIED"
      : "WRITE_FAILED";
    if (errorType === "PERMISSION_DENIED") {
      return Result.err({
        type: errorType,
        path: targetPath,
        operation: "directory",
        cause,
      });
    }
    return Result.err({
      type: errorType,
      path: targetPath,
      cause,
    });
  }
}

/**
 * Create symlink
 */
function createSymlink(options: FileSourceOptions): FileResult {
  const { src, path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);

  // Check if source exists
  if (!fs.pathExistsSync(src)) {
    return Result.err({
      type: "SOURCE_NOT_FOUND",
      path: src,
    });
  }

  const targetCheck = clearTarget(targetPath, "link", force);
  if (!targetCheck.ok) {
    return targetCheck;
  }

  try {
    fs.symlinkSync(src, targetPath);
    return Result.ok({ path: targetPath });
  } catch (cause) {
    return Result.err({
      type: "LINK_FAILED",
      source: src,
      target: targetPath,
      cause,
    });
  }
}

/**
 * Create hardlink
 */
function createHardlink(options: FileSourceOptions): FileResult {
  const { src, path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);

  // Check if source exists
  if (!fs.pathExistsSync(src)) {
    return Result.err({
      type: "SOURCE_NOT_FOUND",
      path: src,
    });
  }

  const targetCheck = clearTarget(targetPath, "hardlink", force);
  if (!targetCheck.ok) {
    return targetCheck;
  }

  try {
    fs.ensureLinkSync(src, targetPath);
    return Result.ok({ path: targetPath });
  } catch (cause) {
    return Result.err({
      type: "LINK_FAILED",
      source: src,
      target: targetPath,
      cause,
    });
  }
}

/**
 * Decrypt SOPS-encrypted file to target path (whole file only).
 */
async function decryptEncrypted(
  options: FileEncryptedOptions,
): Promise<FileResult> {
  const { src, path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);
  const mode = Option.from(options.mode);
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  if (!fs.pathExistsSync(src)) {
    return Result.err({
      type: "SOURCE_NOT_FOUND",
      path: src,
    });
  }

  const targetCheck = clearTarget(targetPath, "encrypted", force);
  if (!targetCheck.ok) {
    return targetCheck;
  }

  if (!(await hasSops())) {
    return Result.err({
      type: "SOPS_NOT_FOUND",
      path: "sops",
    });
  }

  const inputTypeMap: Record<string, string> = {
    yml: "yaml",
    yaml: "yaml",
    json: "json",
    env: "dotenv",
    ini: "ini",
  };
  const strippedExt = extname(src.replace(/\.encrypted$/, "")).slice(1).toLowerCase();
  const inputType = inputTypeMap[strippedExt];

  try {
    if (sudo) {
      const tmp = await Deno.makeTempFile({ prefix: "fig-encrypted-" });
      try {
        if (inputType) {
          await $`sops -d --input-type ${inputType} --output-type ${inputType} --output ${tmp} ${src}`;
        } else {
          await $`sops -d --output ${tmp} ${src}`;
        }
        const cpErr = await cp(tmp, targetPath, { sudo: true });
        if (cpErr) throw cpErr;
        if (Option.isSome(mode)) {
          const err = await chmod(mode, targetPath, { sudo: true });
          if (err) throw err;
        }
      } finally {
        try {
          await Deno.remove(tmp);
        } catch {
          // Best effort cleanup.
        }
      }
    } else {
      if (inputType) {
        await $`sops -d --input-type ${inputType} --output-type ${inputType} --output ${targetPath} ${src}`;
      } else {
        await $`sops -d --output ${targetPath} ${src}`;
      }
      if (Option.isSome(mode)) {
        const err = await chmod(mode, targetPath);
        if (err) throw err;
      }
    }

    return Result.ok({ path: targetPath });
  } catch (error) {
    return Result.err({
      type: "SOPS_FAILED",
      code: getExitCode(error),
      stderr: String(error),
      src,
    });
  }
}

/**
 * Copy file
 */
async function copyFile(options: FileSourceOptions): Promise<FileResult> {
  const { src, path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);
  const mode = Option.from(options.mode);
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  if (!fs.pathExistsSync(src)) {
    return Result.err({ type: "SOURCE_NOT_FOUND", path: src });
  }

  if (fs.pathExistsSync(targetPath)) {
    if (!force) {
      return Result.err({
        type: "TARGET_EXISTS",
        path: targetPath,
        operation: "copy",
      });
    }
    try {
      const err = await rm(targetPath, { sudo });
      if (err) throw err;
    } catch (cause) {
      if (sudo) {
        return Result.err({
          type: "PERMISSION_DENIED",
          path: targetPath,
          operation: "copy" as const,
          cause,
        });
      }
      return Result.err({ type: "WRITE_FAILED", path: targetPath, cause });
    }
  }

  try {
    const err = await cp(src, targetPath, { sudo });
    if (err) throw err;
    if (Option.isSome(mode)) {
      const err = await chmod(mode, targetPath, { sudo });
      if (err) throw err;
    }
    return Result.ok({ path: targetPath });
  } catch (cause) {
    if (sudo) {
      return Result.err({
        type: "PERMISSION_DENIED",
        path: targetPath,
        operation: "copy" as const,
        cause,
      });
    }
    return Result.err({
      type: "COPY_FAILED",
      source: src,
      target: targetPath,
      cause,
    });
  }
}
