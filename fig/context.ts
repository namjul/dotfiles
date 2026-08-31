import { promptSecret } from "@std/cli/prompt-secret";
import { attributes } from "./attributes.ts";
import variables from "../variables.ts";
import {
  resolveSudoAskpass,
  run,
  SUDO_ASKPASS,
  SUDO_TICKET,
  sudoAuthKind,
  type Passphrase,
} from "./run.ts";
import { Variables } from "./types.ts";

type Aspect = {
  dir: string;
  variables: Variables;
};

/**
 * Global context for the current aspect
 */

let aspectContext: Aspect;

/**
 * Initialize the Fig context with the current aspect directory.
 * Must be called once at the start of each aspect.
 */
export function init(aspectDir: string | undefined): void {
  if (aspectDir === undefined) {
    throw new Error(
      "Fig context not initialized. Call init(import.meta.dirname) at the start of your aspect.",
    );
  }
  aspectContext = {
    dir: aspectDir,
    variables: {
      ...attributes,
      ...variables,
    },
  };
}

/**
 * Get the current aspect directory.
 * Throws if init() has not been called.
 */
export function getAspect(): Aspect {
  if (!aspectContext.dir) {
    throw new Error(
      "Fig context not initialized. Call init(import.meta.dirname) at the start of your aspect.",
    );
  }
  return aspectContext;
}

/**
 * Check if context has been initialized
 */
export function isInitialized(): boolean {
  const aspect = getAspect();
  return aspect.dir !== null;
}

export function registerVariablesCallback(
  callback: (v: Variables) => Variables,
): void {
  const aspect = getAspect();
  aspect.variables = Object.assign(
    aspect.variables,
    callback(aspectContext.variables),
  );
}

let _promptedPassphrase: Promise<string> | undefined;

export async function getSudoPassphrase(): Promise<Passphrase | undefined> {
  if (Deno.uid() === 0) return undefined;
  if (await sudoIsCached()) return SUDO_TICKET;

  const helper = resolveSudoAskpass({
    sudoAskpass: Deno.env.get("SUDO_ASKPASS"),
    waylandDisplay: Deno.env.get("WAYLAND_DISPLAY"),
    display: Deno.env.get("DISPLAY"),
    helperOnPath: helperOnPath("wofi"),
    defaultHelper: new URL("../bin/fig-sudo-askpass", import.meta.url).pathname,
  });

  const kind = sudoAuthKind({
    isRoot: false,
    ticketCached: false,
    sudoAskpass: helper,
  });

  if (kind === "askpass" && helper !== undefined) {
    const planted = await run("true", [], {
      env: { ...Deno.env.toObject(), SUDO_ASKPASS: helper },
      passphrase: SUDO_ASKPASS,
    });
    if (planted.exitCode !== 0) {
      throw new Error(`sudo askpass failed: ${planted.stderr}`);
    }
    return SUDO_TICKET;
  }

  if (_promptedPassphrase === undefined) {
    _promptedPassphrase = Promise.resolve(
      promptSecret("sudo passphrase: ") ?? "",
    );
  }
  return _promptedPassphrase;
}

async function sudoIsCached(): Promise<boolean> {
  const { success } = await new Deno.Command("sudo", {
    args: ["-n", "true"],
  }).output();
  return success;
}

function helperOnPath(name: string): boolean {
  const path = Deno.env.get("PATH") ?? "";
  for (const dir of path.split(":")) {
    if (dir === "") continue;
    try {
      Deno.statSync(`${dir}/${name}`);
      return true;
    } catch {
      // keep looking
    }
  }
  return false;
}
