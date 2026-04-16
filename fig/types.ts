import type { Result } from "@gordonb/result/result";
import type { Option } from "@gordonb/result/option";

/**
 * Error types for file operations
 */
export type FileState = "file" | "link" | "hardlink" | "copy" | "directory" | "encrypted";

export type FileError =
  | { type: "SOURCE_NOT_FOUND"; path: string }
  | { type: "TARGET_EXISTS"; path: string; operation: FileState }
  | { type: "SYMLINK_DETECTED"; path: string }
  | { type: "PERMISSION_DENIED"; path: string; operation: FileState; cause: unknown }
  | { type: "WRITE_FAILED"; path: string; cause: unknown }
  | { type: "LINK_FAILED"; source: string; target: string; cause: unknown }
  | { type: "COPY_FAILED"; source: string; target: string; cause: unknown }
  | { type: "SOPS_NOT_FOUND"; path: string }
  | { type: "SOPS_FAILED"; code: number; stderr: string; src: string };

/**
 * Error types for template operations
 */
export type TemplateError =
  | { type: "TEMPLATE_NOT_FOUND"; path: string }
  | { type: "GOMPLATE_FAILED"; code: number; stderr: string };

/**
 * Error types for line operations
 */
export type LineError =
  | { type: "FILE_NOT_READABLE"; path: string; cause: unknown }
  | FileError;

/**
 * Success result value
 */
export interface SuccessValue {
  path: string;
}

/**
 * Result types for operations
 */
export type FileResult = Result<SuccessValue, FileError>;
export type TemplateResult = Result<SuccessValue, TemplateError>;
export type LineResult = Result<SuccessValue, LineError>;

/**
 * Options for file operations
 */
export interface FileOptionsBase {
  path: string;
  force?: boolean;
  mode?: Option<string>;
  sudo?: boolean;
}

export interface FileWriteOptions extends FileOptionsBase {
  state: "file";
  contents: string;
  src?: never;
}

export interface FileSourceOptions extends FileOptionsBase {
  state: "link" | "hardlink" | "copy";
  src: string;
  contents?: never;
}

export interface FileDirectoryOptions extends FileOptionsBase {
  state: "directory";
  src?: never;
  contents?: never;
}

/** Whole-file decrypt via SOPS (`sops -d --output …`). No field-level `--extract`. */
export interface FileEncryptedOptions extends FileOptionsBase {
  state: "encrypted";
  src: string;
  contents?: never;
}

export type FileOptions =
  | FileWriteOptions
  | FileSourceOptions
  | FileDirectoryOptions
  | FileEncryptedOptions;

/**
 * Options for template operations
 */
export interface TemplateOptions {
  src: string;
  path: string;
  context?: Record<string, unknown>;
}

/**
 * Options for line operations
 */
export interface LineOptions {
  path: string;
  line: string;
  regexp?: RegExp | string;
  state?: "present" | "absent";
  mode?: Option<string>;
  sudo?: boolean;
}

/**
 * Path interface - string-like with methods
 */
export interface Path {
  toString(): string;
  valueOf(): string;
  strip(ext: string): Path;
  join(...parts: (string | Path)[]): Path;
  basename: Path;
  dirname: Path;
  resolve: Path;
  expand: Path;
  [Symbol.iterator](): Iterator<string>;
}
