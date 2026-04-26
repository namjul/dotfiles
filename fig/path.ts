import { os, path as zxPath } from "zx";
import { getAspect } from "./context.ts";
import type { Path } from "./types.ts";
import { root } from "./root.ts";

const INSPECT = Symbol.for("nodejs.util.inspect.custom");

export interface path {
  (...components: (string)[]): Path;
  aspect: Path;
  home: Path;
  root: Path;
}

function path(...components: Array<string>): Path {
  // Unwrap (possible) Path string-like(s) back to primitive string.
  const string = zxPath.join(
    ...components.map((component) => component.toString()),
  );

  return Object.defineProperties(new String(string), {
    basename: {
      get() {
        return path(zxPath.basename(string));
      },
    },

    components: {
      get() {
        return string.split(zxPath.sep).map((component) => path(component));
      },
    },

    dirname: {
      get() {
        return path(zxPath.dirname(string));
      },
    },

    expand: {
      get() {
        if (string === "~") {
          return path(os.homedir());
        } else if (string.startsWith("~/")) {
          return path(zxPath.join(os.homedir(), string.slice(2)));
        }
        return path(string);
      },
    },

    join: {
      value: (...components: Array<string>) => {
        return path(
          zxPath.normalize(
            zxPath.join(string, ...components.map((c) => c.toString())),
          ),
        );
      },
    },

    last: {
      value: (count: number) => {
        return string
          .split(zxPath.sep)
          .slice(-count)
          .map((component) => path(component));
      },
    },

    resolve: {
      get() {
        if (string.startsWith("~/")) {
          return path(
            zxPath.normalize(zxPath.join(os.homedir(), string.slice(2))),
          );
        }
        return path(zxPath.resolve(string));
      },
    },

    simplify: {
      get() {
        const home = os.homedir();

        if (string.startsWith(home)) {
          return path(zxPath.join("~", string.slice(home.length)));
        } else {
          return path(zxPath.relative("", string));
        }
      },
    },

    strip: {
      value: (extension: string) => {
        return path(
          zxPath.join(
            zxPath.dirname(string),
            zxPath.basename(string, extension),
          ),
        );
      },
    },

    [INSPECT]: {
      value: () => string,
    },

    [Symbol.iterator]: {
      value: function* () {
        for (const char of string) {
          yield char;
        }
      },
    },
  }) as Path;
}

Object.defineProperty(path, "aspect", {
  get: () => path(getAspect().dir),
});

export default Object.assign(path, {
  home: path("~").expand,
  root: path(root),
}) as path;
