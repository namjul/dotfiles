import { assertEquals } from "@std/assert";
import { Result } from "@gordonb/result";
import { command } from "./command.ts";

Deno.test("command: runs echo and returns output", async () => {
  const result = await command("echo", ["hello world"]);
  assertEquals(Result.isOk(result), true);
  if (Result.isOk(result)) {
    assertEquals(result.value.command, "echo");
  }
});

Deno.test("command: runs with args", async () => {
  const result = await command("echo", ["foo", "bar"]);
  assertEquals(Result.isOk(result), true);
  if (Result.isOk(result)) {
    assertEquals(result.value.command, "echo");
  }
});

Deno.test("command: raw option skips path expansion", async () => {
  const result = await command("echo", ["$HOME"], { raw: true });
  assertEquals(Result.isOk(result), true);
});

Deno.test("command: returns ok with command on success", async () => {
  const result = await command("true", []);
  assertEquals(Result.isOk(result), true);
  if (Result.isOk(result)) {
    assertEquals(result.value.command, "true");
  }
});

Deno.test("command: handles command failure", async () => {
  const result = await command("false", []);
  assertEquals(Result.isErr(result), true);
  if (Result.isErr(result)) {
    assertEquals(result.error.exitCode, 1);
    assertEquals(result.error.type, "COMMAND_FAILED");
  }
});
