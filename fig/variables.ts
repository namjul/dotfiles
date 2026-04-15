import { fs, glob } from "zx";
import { getAspectDir } from "./context.ts";
import { attributes } from "./attributes.ts";
import { path } from "./path.ts";
import type { Path } from "./types.ts";

/**
 * Default variables (can be overridden)
 */
const defaults: Record<string, unknown> = {
  editor: "nvim",
  shell: "bash",
};

/**
 * Platform-specific variables
 */
const platformVars: Record<string, Record<string, unknown>> = {
  darwin: {
    package_manager: "brew",
  },
  linux: {
    package_manager: "nala",
  },
};

/**
 * Aspect-specific variables (set at runtime)
 */
let aspectVars: Record<string, unknown> = {};

/**
 * Set aspect-specific variables
 */
export function setAspectVars(vars: Record<string, unknown>): void {
  aspectVars = vars;
}

/**
 * Get all variables merged together
 */
export function all(): Record<string, unknown> {
  return {
    ...attributes,
    ...defaults,
    ...(platformVars[attributes.platform] || {}),
    ...aspectVars,
  };
}

/**
 * Get a specific variable
 */
export function get(name: string): unknown {
  return all()[name];
}

/**
 * Get paths from a subdirectory of the aspect
 * Returns Path objects representing relative paths from the subdirectory
 */
export async function paths(dir: "files" | "templates"): Promise<Path[]> {
  const aspectDir = getAspectDir();
  const searchDir = `${aspectDir}/${dir}`;

  // Get all files (not directories) recursively
  const allEntries = await glob(`${searchDir}/**/*`, {
    absolute: true,
    dot: true,
  });

  const result: Path[] = [];
  for (const entry of allEntries) {
    // Check if it's a file (not directory)
    try {
      const stat = await fs.stat(entry);
      if (stat.isFile()) {
        // Get relative path from the search directory
        const relativePath = entry.replace(`${searchDir}/`, "");
        result.push(path(relativePath));
      }
    } catch {
      // Skip if can't stat
    }
  }

  return result;
}
