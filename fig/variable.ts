import { getAspect } from "./context.ts";
import { attributes } from "./attributes.ts";
import path from "./path.ts";
import type { JSONValue, Path } from "./types.ts";
import { assert } from "./assert.ts";

export function variable(name: string, fallback?: JSONValue) {
  const aspectVars = getAspect().variables
  return Object.prototype.hasOwnProperty.call(aspectVars, name) ? aspectVars[name] : fallback || null;
}

variable.all = (): Record<string, unknown> => {
  const aspectVars = getAspect().variables
  return {
    ...attributes,
    ...aspectVars,
  };
}

variable.string = (name: string, fallback?: string): string => {
  const value = variable(name, fallback);

  assert(
    typeof value === 'string',
    `Expected variable ${name} to have type string but it was ${typeof value}`,
  );

  return value;
};

variable.array = (
  name: string,
  fallback?: Array<JSONValue>,
): Array<JSONValue> => {
  const value = variable(name, fallback);
  assert(Array.isArray(value), `Expected variable ${name} to be an array`);
  return value;
};

variable.path = (name: string, fallback?: string): Path => {
  const value = variable.string(name, fallback);
  return path(value);
}

variable.paths = (name: string, fallback?: Array<string>): Array<Path> => {
  const value = variable.array(name, fallback);

  return value.map((v) => {
    assert(
      typeof v === 'string',
      `Expected variable ${name} to be an array of strings but it contained a ${typeof v}`,
    );
    return path(v);
  });

  // const aspectDir = getAspectDir();
  // const searchDir = `${aspectDir}/${dir}`;
  //
  // // Get all files (not directories) recursively
  // const allEntries = await glob(`${searchDir}/**/*`, {
  //   absolute: true,
  //   dot: true,
  // });
  //
  // const result: Path[] = [];
  // for (const entry of allEntries) {
  //   // Check if it's a file (not directory)
  //   try {
  //     const stat = await fs.stat(entry);
  //     if (stat.isFile()) {
  //       // Get relative path from the search directory
  //       const relativePath = entry.replace(`${searchDir}/`, "");
  //       result.push(path(relativePath));
  //     }
  //   } catch {
  //     // Skip if can't stat
  //   }
  // }
  //
  // return result;
}
