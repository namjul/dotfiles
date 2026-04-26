import { Result } from "@gordonb/result";
import { $, fs } from "zx";
import type {
  TemplateError,
  TemplateOptions,
  TemplateResult,
} from "../types.ts";
import { getAspect } from "../context.ts";
import toPath from "../path.ts";

function getExitCode(error: unknown): number {
  if (typeof error === "object" && error !== null && "exitCode" in error) {
    const value = Reflect.get(error, "exitCode");
    return typeof value === "number" ? value : 1;
  }
  return 1;
}

/**
 * Check if gomplate is available
 */
async function hasGomplate(): Promise<boolean> {
  try {
    await $`which gomplate`;
    return true;
  } catch {
    return false;
  }
}

/**
 * Simple JavaScript-based template renderer
 * Replaces {{ .key }} with values from context
 */
export function renderTemplate(
  content: string,
  context: Record<string, unknown>,
): string {
  return content.replace(
    /\{\{\s*\.([a-zA-Z_][a-zA-Z0-9_]*)\s*\}\}/g,
    (match, key) => {
      const value = context[key];
      return value !== undefined ? String(value) : match;
    },
  );
}

/**
 * Write context to a secure temp file and always clean it up.
 */
export async function withTempContextFile<T>(
  context: Record<string, unknown>,
  run: (contextFilePath: string) => Promise<T>,
): Promise<T> {
  const tmpFile = await Deno.makeTempFile({
    prefix: "fig-context-",
    suffix: ".json",
  });
  try {
    await Deno.writeTextFile(tmpFile, JSON.stringify(context));
    return await run(tmpFile);
  } finally {
    try {
      await Deno.remove(tmpFile);
    } catch {
      // Best effort cleanup.
    }
  }
}

/**
 * Template operation - render templates using gomplate (if available) or simple JS fallback
 */
export async function template(
  { src, path, context }: TemplateOptions,
): Promise<TemplateResult> {

  const targetPath = toPath(path).resolve.toString();
  if (src) {
    src = toPath(src).resolve.toString();
  }

  // Check if template exists
  if (!fs.pathExistsSync(src)) {
    return Result.err({
      type: "TEMPLATE_NOT_FOUND",
      path: src,
    });
  }

  // Prepare context
  const variables = {
    ...getAspect().variables,
    ...context
  }

  // Ensure parent directory exists
  const targetDir = targetPath.split("/").slice(0, -1).join("/") || "/";
  fs.ensureDirSync(targetDir);

  // Try gomplate first, fall back to simple JS renderer
  const useGomplate = await hasGomplate();

  if (useGomplate) {
    // Use gomplate with context from a secure temp file.
    try {
      await withTempContextFile(variables, async (contextFilePath) => {
        await $`gomplate --file ${src} --out ${targetPath} --context variables=${contextFilePath}`;
      });
      return Result.ok({ path: targetPath });
    } catch (error) {
      const templateError: TemplateError = {
        type: "GOMPLATE_FAILED",
        code: getExitCode(error),
        stderr: String(error),
      };
      return Result.err(templateError);
    }
  } else {
    // Fallback: simple JavaScript template renderer
    try {
      const content = fs.readFileSync(src, "utf8");
      const rendered = renderTemplate(content, variables);
      fs.writeFileSync(targetPath, rendered);
      return Result.ok({ path: targetPath });
    } catch (error) {
      const templateError: TemplateError = {
        type: "GOMPLATE_FAILED",
        code: 1,
        stderr: String(error),
      };
      return Result.err(templateError);
    }
  }
}
