#!/usr/bin/env -S deno run --allow-all
/**
 * # mise description="Meta aspect for @fig/ framework"
 * # mise alias="meta"
 */

import { init } from "fig";

init(import.meta.dirname);

await import("./tests.ts");
await import("./globals.ts");
