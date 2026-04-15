import { assertEquals } from "@std/assert";
import { Result } from "@gordonb/result";
import { line } from "./line.ts";

Deno.test("line(): handles RegExp with global flag deterministically", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/config.conf`;
  try {
    await Deno.writeTextFile(target, "foo=1\nbar=2\n");

    const first = await line({
      path: target,
      line: "bar=42",
      regexp: /^(foo|bar)=/g,
    });
    assertEquals(Result.isErr(first), false);

    const second = await line({
      path: target,
      line: "bar=42",
      regexp: /^(foo|bar)=/g,
    });
    assertEquals(Result.isErr(second), false);

    const content = await Deno.readTextFile(target);
    assertEquals(content, "bar=42\nbar=2\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("line(): removes all matching lines with sticky regex", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/remove.conf`;
  try {
    await Deno.writeTextFile(target, "enabled=true\nenabled=false\nother=1\n");

    const result = await line({
      path: target,
      line: "enabled=true",
      regexp: /^enabled=/y,
      state: "absent",
    });
    assertEquals(Result.isErr(result), false);

    const content = await Deno.readTextFile(target);
    assertEquals(content, "other=1\n");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});

Deno.test("line(): adds first line to empty file without leading newline", async () => {
  const tmpDir = await Deno.makeTempDir();
  const target = `${tmpDir}/empty.conf`;
  try {
    await Deno.writeTextFile(target, "");

    const result = await line({
      path: target,
      line: "enabled=true",
    });
    assertEquals(Result.isErr(result), false);

    const content = await Deno.readTextFile(target);
    assertEquals(content, "enabled=true");
  } finally {
    await Deno.remove(tmpDir, { recursive: true });
  }
});
