import { assertEquals } from "@std/assert";
import { path } from "./path.ts";

Deno.test("path(): preserves filesystem root", () => {
  const rootPath = path("/");
  assertEquals(rootPath.toString(), "/");
});

Deno.test("path().dirname: dirname of root stays root", () => {
  const dirname = path("/").dirname.toString();
  assertEquals(dirname, "/");
});
