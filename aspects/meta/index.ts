#!/usr/bin/env -S deno run --allow-all
/**
 * # mise description="Meta aspect for @fig/ framework"
 * # mise alias="meta"
 */

import { init, variables } from "fig";

init(import.meta.dirname);

variables(() => ({
  files: ["hello.txt", "hard-state.json"],
  templates: ["config.toml.tmpl"],
}));

await import("./tests.ts");
await import("./globals.ts");
