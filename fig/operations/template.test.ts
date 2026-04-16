import { assertEquals, assertRejects, assertStringIncludes } from "@std/assert";
import { Result } from "@gordonb/result";
import { renderTemplate, template, withTempContextFile } from "./template.ts";

Deno.test("renderTemplate(): replaces known placeholders and keeps unknown", () => {
  const output = renderTemplate(
    "hello={{ .user }} shell={{ .shell }} unknown={{ .missing }}",
    { user: "alice", shell: "zsh" },
  );
  assertEquals(output, "hello=alice shell=zsh unknown={{ .missing }}");
});

Deno.test("withTempContextFile(): always cleans up temp file on callback failure", async () => {
  let tempPath = "";
  const error = await assertRejects(() =>
    withTempContextFile({ token: "sensitive" }, (path) => {
      tempPath = path;
      // Intentional: simulate callback failure path for cleanup verification.
      throw new Error("forced failure");
    })
  );
  assertStringIncludes(String(error), "forced failure");
  assertEquals(tempPath === "", false);
  await assertRejects(() => Deno.stat(tempPath), Deno.errors.NotFound);
});

Deno.test("template(): returns TEMPLATE_NOT_FOUND when source is missing", async () => {
  const tmpDir = await Deno.makeTempDir();
  try {
    const result = await template({
      src: `${tmpDir}/missing.tmpl`,
      path: `${tmpDir}/out.conf`,
    });
    assertEquals(Result.isOk(result), false);
    if (Result.isErr(result)) {
      assertEquals(result.error.type, "TEMPLATE_NOT_FOUND");
    }
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("template(): renders variables into output", async () => {
  const tmpDir = await Deno.makeTempDir();
  const src = `${tmpDir}/config.tmpl`;
  const target = `${tmpDir}/config.out`;
  try {
    await Deno.writeTextFile(src, "user={{ .user }} shell={{ .shell }}");

    const result = await template({
      src,
      path: target,
      context: { user: "alice", shell: "zsh" },
    });
    assertEquals(Result.isErr(result), false);

    const content = await Deno.readTextFile(target);
    assertStringIncludes(content, "user=alice");
    assertStringIncludes(content, "shell=zsh");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});
