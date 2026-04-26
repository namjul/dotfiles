/**
 * Fig - Configuration management framework for Deno
 *
 * Usage:
 *   import { init, file, template, line, variable, path, Result } from "@fig/mod.ts";
 *
 *   init(import.meta.dirname);
 *
 *   const result = file({ src: "...", path: "...", state: "link" });
 */

// Re-export Result type
export { Result } from "@gordonb/result";
export { assert, assertNever, fail } from "./assert.ts";

// Context
export { init } from "./context.ts";

// Path
export { default as path } from "./path.ts";
export type { Path } from "./types.ts";
export { root } from "./root.ts";

// Variables
export { variable } from "./variable.ts";
export { variables } from "./variables.ts";

// Attributes
export { attributes } from "./attributes.ts";

// Operations
export { file } from "./operations/file.ts";
export { template } from "./operations/template.ts";
export { line } from "./operations/line.ts";
export { command } from "./operations/command.ts";
export { fetch } from "./operations/fetch.ts";

// Resouces
export * as resource from "./resource.ts";
