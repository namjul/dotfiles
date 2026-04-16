import { assertEquals } from "@std/assert";
import { Result } from "@gordonb/result";
import type { FileOptions } from "../types.ts";
import { file } from "./file.ts";

async function sopsAvailable(): Promise<boolean> {
  const cmd = new Deno.Command("which", { args: ["sops"] });
  const { success } = await cmd.output();
  return success;
}

Deno.test("file(): writes empty contents", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/empty.txt`;
  try {
    const result = await file({
      path: target,
      state: "file",
      contents: "",
    });
    assertEquals(Result.isErr(result), false);

    const content = await Deno.readTextFile(target);
    assertEquals(content, "");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): returns SOURCE_NOT_FOUND for link/copy/hardlink missing source", async () => {
  const tmpDir = await Deno.makeTempDir();
  try {
    const cases: FileOptions[] = [
      {
        path: `${tmpDir}/target-link`,
        src: `${tmpDir}/missing-source`,
        state: "link",
      },
      {
        path: `${tmpDir}/target-copy`,
        src: `${tmpDir}/missing-source`,
        state: "copy",
      },
      {
        path: `${tmpDir}/target-hardlink`,
        src: `${tmpDir}/missing-source`,
        state: "hardlink",
      },
      {
        path: `${tmpDir}/target-encrypted`,
        src: `${tmpDir}/missing-encrypted`,
        state: "encrypted",
      },
    ];

    for (const options of cases) {
      const result = await file(options);
      assertEquals(Result.isOk(result), false);
      if (Result.isErr(result)) {
        assertEquals(result.error.type, "SOURCE_NOT_FOUND");
      }
    }
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): returns TARGET_EXISTS without force and overwrites with force", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/target.txt`;
  try {
    await Deno.writeTextFile(`${tmpDir}/source.txt`, "source");
    await Deno.writeTextFile(target, "existing");

    const withoutForce = await file({
      path: target,
      state: "file",
      contents: "updated",
    });
    assertEquals(Result.isOk(withoutForce), false);
    if (Result.isErr(withoutForce)) {
      assertEquals(withoutForce.error.type, "TARGET_EXISTS");
    }

    const withForce = await file({
      path: target,
      state: "file",
      contents: "updated",
      force: true,
    });
    assertEquals(Result.isErr(withForce), false);

    const content = await Deno.readTextFile(target);
    assertEquals(content, "updated");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): creates directory and is idempotent on rerun", async () => {
  const tmpDir = await Deno.makeTempDir();
  const targetDir = `${tmpDir}/nested/config`;
  try {
    const first = await file({
      path: targetDir,
      state: "directory",
    });
    assertEquals(Result.isErr(first), false);

    const stat = await Deno.stat(targetDir);
    assertEquals(stat.isDirectory, true);

    const second = await file({
      path: targetDir,
      state: "directory",
    });
    assertEquals(Result.isErr(second), false);
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): returns TARGET_EXISTS for directory when file exists and no force", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/exists`;
  try {
    await Deno.writeTextFile(target, "not a directory");
    const result = await file({
      path: target,
      state: "directory",
    });
    assertEquals(Result.isOk(result), false);
    if (Result.isErr(result)) {
      assertEquals(result.error.type, "TARGET_EXISTS");
    }
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): applies mode for directory", async () => {
  const tmpDir = await Deno.makeTempDir();
  const targetDir = `${tmpDir}/mode-check`;
  try {
    const result = await file({
      path: targetDir,
      state: "directory",
      mode: "0700",
    });
    assertEquals(Result.isErr(result), false);

    const stat = await Deno.stat(targetDir);
    assertEquals(stat.mode === null, false);
    const mode = (stat.mode ?? 0) & 0o777;
    assertEquals(mode, 0o700);
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("file(): returns TARGET_EXISTS for encrypted without force", async () => {
  const tmpDir = await Deno.makeTempDir();
  const src = `${tmpDir}/src.sops`;
  const target = `${tmpDir}/out.txt`;
  try {
    await Deno.writeTextFile(src, "placeholder");
    await Deno.writeTextFile(target, "existing");
    const result = await file({
      path: target,
      src,
      state: "encrypted",
    });
    assertEquals(Result.isOk(result), false);
    if (Result.isErr(result)) {
      assertEquals(result.error.type, "TARGET_EXISTS");
    }
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test({
  name:
    "file(): encrypted returns SOPS_FAILED for non-SOPS source when sops is installed",
  ignore: !(await sopsAvailable()),
  fn: async () => {
    const tmpDir = await Deno.makeTempDir();
    const src = `${tmpDir}/plain.txt`;
    const target = `${tmpDir}/out.txt`;
    try {
      await Deno.writeTextFile(src, "not a sops file");
      const result = await file({
        path: target,
        src,
        state: "encrypted",
      });
      assertEquals(Result.isOk(result), false);
      if (Result.isErr(result)) {
        assertEquals(result.error.type, "SOPS_FAILED");
      }
    } finally {
      await Deno.remove(tmpDir, { recursive: true });
    }
  },
});

Deno.test("file(): returns Result error instead of throwing on inaccessible parent directory", async () => {
  const tmpDir = await Deno.makeTempDir();
  const blockedDir = `${tmpDir}/blocked`;
  const target = `${blockedDir}/child/config.txt`;

  try {
    await Deno.mkdir(blockedDir);
    await Deno.chmod(blockedDir, 0o000);

    let threw = false;
    let result: Awaited<ReturnType<typeof file>> | null = null;
    try {
      result = await file({
        path: target,
        state: "file",
        contents: "x",
      });
    } catch {
      threw = true;
    }
    assertEquals(threw, false);
    assertEquals(result === null, false);
    if (result !== null) {
      assertEquals(Result.isOk(result), false);
    }
  } finally {
    await Deno.chmod(blockedDir, 0o700).catch(() => undefined);
    await Deno.remove(tmpDir, { recursive: true });
  }
});
