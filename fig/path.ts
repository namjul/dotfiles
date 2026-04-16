import { os, path as zxPath } from "zx";
import { getAspectDir } from "./context.ts";
import type { Path } from "./types.ts";

const INSPECT = Symbol.for("nodejs.util.inspect.custom");

/**
 * Path function with namespace properties
 */
export interface PathNamespace {
  (...components: (string | Path)[]): Path;
  home: Path;
  aspect: Path;
}

/**
 * Create a Path object with methods via Object.defineProperties
 */
function createPath(str: string): Path {
  // Normalize the path string
  const collapsed = str.replace(/\/+/g, "/");
  const normalized = collapsed === "/" ? "/" : collapsed.replace(/\/$/, "");

  const string = new String(normalized);

  return Object.defineProperties(string, {
    basename: {
      get() {
        return createPath(zxPath.basename(normalized));
      },
    },

    dirname: {
      get() {
        return createPath(zxPath.dirname(normalized));
      },
    },

    expand: {
      get() {
        if (normalized === "~") {
          return createPath(os.homedir());
        } else if (normalized.startsWith("~/")) {
          return createPath(zxPath.join(os.homedir(), normalized.slice(2)));
        }
        return createPath(normalized);
      },
    },

    resolve: {
      get() {
        if (normalized.startsWith("~/")) {
          return createPath(
            zxPath.normalize(zxPath.join(os.homedir(), normalized.slice(2))),
          );
        }
        return createPath(zxPath.resolve(normalized));
      },
    },

    join: {
      value: (...parts: (string | Path)[]) => {
        const partStrings = parts.map((p) =>
          typeof p === "string" ? p : p.toString()
        );
        return createPath(
          zxPath.normalize(zxPath.join(normalized, ...partStrings)),
        );
      },
    },

    strip: {
      value: (extension: string) => {
        return createPath(
          zxPath.join(
            zxPath.dirname(normalized),
            zxPath.basename(normalized, extension),
          ),
        );
      },
    },

    [INSPECT]: {
      value: () => normalized,
    },

    toString: {
      value: () => normalized,
    },

    valueOf: {
      value: () => normalized,
    },

    [Symbol.iterator]: {
      value: function* () {
        for (const char of normalized) {
          yield char;
        }
      },
    },
  }) as unknown as Path;
}

/**
 * Path function - creates Path from components
 */
export function makePath(...components: (string | Path)[]): Path {
  const parts = components.map((c) => typeof c === "string" ? c : c.toString());
  return createPath(zxPath.join(...parts));
}

/**
 * Create the path function with namespace properties
 */
function createPathNamespace(): PathNamespace {
  const fn = (...components: (string | Path)[]) => makePath(...components);

  Object.defineProperty(fn, "home", {
    get: () => createPath(os.homedir()),
  });

  Object.defineProperty(fn, "aspect", {
    get: () => createPath(getAspectDir()),
  });

  return fn as PathNamespace;
}

/**
 * Path namespace with function and properties
 */
export const path = createPathNamespace();
