import { attributes } from "./attributes.ts";
import variables from "../variables.ts";
import { Variables } from "./types.ts";
import { promptSecret } from "@std/cli/prompt-secret";

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

let _sudoPassphrase: Promise<string> | undefined;

export function getSudoPassphrase(): Promise<string> {
  if (_sudoPassphrase === undefined) {
    _sudoPassphrase = resolveSudoPassphrase();
  }
  return _sudoPassphrase;
}

async function resolveSudoPassphrase(): Promise<string> {
  // Already root — sudo unavailable and unnecessary.
  if (Deno.uid() === 0) return "";
  return promptSecret("sudo passphrase: ") ?? "";
}
