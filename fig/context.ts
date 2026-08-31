import { promptSecret } from "@std/cli/prompt-secret";
import { attributes } from "./attributes.ts";
import variables from "../variables.ts";
import { resolveSudoAskpass, SUDO_TICKET, type Passphrase } from "./run.ts";
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

  const helper = resolveSudoAskpass(Deno.env.get("SUDO_ASKPASS"));

  if (_promptedPassphrase === undefined) {
    _promptedPassphrase = helper !== undefined
      ? obtainAskpass(helper)
      : Promise.resolve(promptSecret("sudo passphrase: ") ?? "");
  }
  return _promptedPassphrase;
}

async function obtainAskpass(helper: string): Promise<string> {
  const result = await new Deno.Command(helper, {
    args: [],
    stdin: "null",
    stdout: "piped",
    stderr: "piped",
  }).output();
  if (!result.success) {
    throw new Error(
      `sudo askpass failed: ${new TextDecoder().decode(result.stderr)}`,
    );
  }
  return new TextDecoder().decode(result.stdout).replace(/\r?\n$/, "");
}

async function sudoIsCached(): Promise<boolean> {
  const { success } = await new Deno.Command("sudo", {
    args: ["-n", "true"],
  }).output();
  return success;
}

