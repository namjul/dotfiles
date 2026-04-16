import { Result } from "@gordonb/result";
import { fs } from "zx";
import { file } from "./file.ts";
import type { LineError, LineOptions, LineResult } from "../types.ts";

function createLineMatcher(regexp: RegExp | string | undefined): RegExp | null {
  if (regexp === undefined) {
    return null;
  }
  if (regexp instanceof RegExp) {
    // Drop stateful flags so repeated `.test()` calls are deterministic across lines.
    const stableFlags = regexp.flags.replace(/[gy]/g, "");
    return new RegExp(regexp.source, stableFlags);
  }
  return new RegExp(regexp);
}

/**
 * Line operation - manage lines in files idempotently
 */
export async function line(options: LineOptions): Promise<LineResult> {
  const { path: filePath, line: lineContent, regexp, state = "present" } =
    options;

  let content: string;
  try {
    content = fs.readFileSync(filePath, "utf8");
  } catch {
    // File doesn't exist, start with empty content
    content = "";
  }

  const lines = content === "" ? [] : content.split("\n");
  const normalizedLine = lineContent.trimEnd();

  // Create regex if string provided
  const regex = createLineMatcher(regexp);

  let modified = false;
  let found = false;

  if (state === "present") {
    // Ensure line is present
    for (let i = 0; i < lines.length; i++) {
      const current = lines[i];

      if (
        current !== undefined &&
        (regex ? regex.test(current) : current === normalizedLine)
      ) {
        found = true;
        if (current !== normalizedLine) {
          lines[i] = normalizedLine;
          modified = true;
        }
        break;
      }
    }

    if (!found) {
      // Add line to end
      if (lines.length > 0 && lines[lines.length - 1] !== "") {
        lines.push("");
      }
      lines.push(normalizedLine);
      modified = true;
    }
  } else {
    // Remove line
    for (let i = lines.length - 1; i >= 0; i--) {
      const current = lines[i];

      if (
        current !== undefined &&
        (regex ? regex.test(current) : current === normalizedLine)
      ) {
        lines.splice(i, 1);
        modified = true;
      }
    }
  }

  if (!modified) {
    // No changes needed
    return Result.ok({ path: filePath });
  }

  // Build file options conditionally
  const fileOptions: Parameters<typeof file>[0] = {
    path: filePath,
    contents: lines.join("\n"),
    state: "file",
    force: true, // Always overwrite since we're modifying
  };

  if (options.mode !== undefined) {
    fileOptions.mode = options.mode;
  }
  if (options.sudo !== undefined) {
    fileOptions.sudo = options.sudo;
  }

  // Write modified content using file operation
  const result = await file(fileOptions);

  if (Result.isErr(result)) {
    return Result.err(result.error as LineError);
  }

  return Result.ok({ path: filePath });
}
