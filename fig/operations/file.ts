import { Result } from "@gordonb/result";
import * as Option from "@gordonb/result/option";
import { fs, $ } from "zx";
import { writeFile } from "atomically";
import { path as toPath } from "../path.ts";
import type {
  FileOptions,
  FileResult,
  FileError,
  FileState,
  FileDirectoryOptions,
  FileEncryptedOptions,
  FileSourceOptions,
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
  try {
    await $`which sops`;
    return true;
  } catch {
    return false;
  }
}

/**
 * File operation - atomic file management
 */
export async function file(options: FileOptions): Promise<FileResult> {
  const resolved = toPath(options.path).expand.resolve;
  const targetPath = resolved.toString();
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  try {
    // Check for symlink directory (safety check)
    const targetDir = targetPath.split("/").slice(0, -1).join("/") || "/";
    if (fs.pathExistsSync(targetDir) && fs.lstatSync(targetDir).isSymbolicLink()) {
      return Result.err({
        type: "SYMLINK_DETECTED",
        path: targetDir,
      });
    }

    // Ensure parent directory exists
    fs.ensureDirSync(targetDir);
  } catch (cause) {
    const errorType: FileError["type"] = sudo ? "PERMISSION_DENIED" : "WRITE_FAILED";
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
      return copyFile({ ...options, path: targetPath });
    case "directory":
      return await ensureDirectory({ ...options, path: targetPath });
    case "encrypted":
      return await decryptEncrypted({ ...options, path: targetPath });
  }
}

/**
 * Write file contents atomically
 */
async function writeFileContent(options: FileWriteOptions): Promise<FileResult> {
  const { path, contents } = options;
  const mode = Option.from(options.mode);
  const sudo = Option.unwrapOr(Option.from(options.sudo), false);

  // Check if target exists and force is not set
  if (fs.pathExistsSync(path) && !Option.unwrapOr(Option.from(options.force), false)) {
    return Result.err({
      type: "TARGET_EXISTS",
      path,
      operation: "file",
    });
  }

  try {
    if (sudo) {
      // Use zx with sudo for privileged paths.
      const tmp = `/tmp/fig-${Date.now()}-${Math.random().toString(36).slice(2)}`;
      fs.writeFileSync(tmp, contents);
      try {
        await $`sudo cp ${tmp} ${path}`;
        if (Option.isSome(mode)) {
          await $`sudo chmod ${mode} ${path}`;
        }
      } finally {
        fs.removeSync(tmp);
      }
    } else {
      // Use atomically for non-sudo writes.
      if (Option.isSome(mode)) {
        await writeFile(path, contents, { mode });
      } else {
        await writeFile(path, contents);
      }
    }

    return Result.ok({ path });
  } catch (cause) {
    const errorType: FileError["type"] = sudo ? "PERMISSION_DENIED" : "WRITE_FAILED";
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

function ensureTargetWritable(
  targetPath: string,
  operation: FileState,
  force: boolean,
): FileResult | null {
  try {
    if (!fs.pathExistsSync(targetPath)) {
      return null;
    }

    if (!force) {
      return Result.err({
        type: "TARGET_EXISTS",
        path: targetPath,
        operation,
      });
    }

    fs.removeSync(targetPath);
    return null;
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
async function ensureDirectory(options: FileDirectoryOptions): Promise<FileResult> {
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
      await $`sudo mkdir -p ${targetPath}`;
      if (Option.isSome(mode)) {
        await $`sudo chmod ${mode} ${targetPath}`;
      }
    } else {
      fs.ensureDirSync(targetPath);
      if (Option.isSome(mode)) {
        fs.chmodSync(targetPath, mode);
      }
    }
    return Result.ok({ path: targetPath });
  } catch (cause) {
    const errorType: FileError["type"] = sudo ? "PERMISSION_DENIED" : "WRITE_FAILED";
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

  const targetCheck = ensureTargetWritable(targetPath, "link", force);
  if (targetCheck !== null) {
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

  const targetCheck = ensureTargetWritable(targetPath, "hardlink", force);
  if (targetCheck !== null) {
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
async function decryptEncrypted(options: FileEncryptedOptions): Promise<FileResult> {
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

  const targetCheck = ensureTargetWritable(targetPath, "encrypted", force);
  if (targetCheck !== null) {
    return targetCheck;
  }

  if (!(await hasSops())) {
    return Result.err({
      type: "SOPS_NOT_FOUND",
      path: "sops",
    });
  }

  try {
    if (sudo) {
      const tmp = await Deno.makeTempFile({ prefix: "fig-encrypted-" });
      try {
        await $`sops -d --output ${tmp} ${src}`;
        await $`sudo cp ${tmp} ${targetPath}`;
        if (Option.isSome(mode)) {
          await $`sudo chmod ${mode} ${targetPath}`;
        }
      } finally {
        try {
          await Deno.remove(tmp);
        } catch {
          // Best effort cleanup.
        }
      }
    } else {
      await $`sops -d --output ${targetPath} ${src}`;
      if (Option.isSome(mode)) {
        fs.chmodSync(targetPath, mode);
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
function copyFile(options: FileSourceOptions): FileResult {
  const { src, path: targetPath } = options;
  const force = Option.unwrapOr(Option.from(options.force), false);
  const mode = Option.from(options.mode);

  // Check if source exists
  if (!fs.pathExistsSync(src)) {
    return Result.err({
      type: "SOURCE_NOT_FOUND",
      path: src,
    });
  }

  const targetCheck = ensureTargetWritable(targetPath, "copy", force);
  if (targetCheck !== null) {
    return targetCheck;
  }

  try {
    fs.copySync(src, targetPath);

    if (Option.isSome(mode)) {
      fs.chmodSync(targetPath, mode);
    }

    return Result.ok({ path: targetPath });
  } catch (cause) {
    return Result.err({
      type: "COPY_FAILED",
      source: src,
      target: targetPath,
      cause,
    });
  }
}
