import { randomBytes } from "node:crypto";
import type { Readable, Writable } from "node:stream";
import { $ } from "zx";

export const SUDO_TICKET: unique symbol = Symbol("sudo-ticket");

export type Passphrase = string | typeof SUDO_TICKET;

export function resolveSudoAskpass(
  sudoAskpass: string | undefined,
): string | undefined {
  if (sudoAskpass === undefined || sudoAskpass === "") {
    return undefined;
  }
  return sudoAskpass;
}

type RunOptions = {
  chdir?: string;
  env?: NodeJS.ProcessEnv;
  passphrase?: Passphrase;
};

export type RunResult = {
  command: string;
  exitCode: number;
  stdout: string;
  stderr: string;
};

export function sudoCommandLine(
  command: string,
  args: ReadonlyArray<string>,
  options: {
    readonly isRoot: boolean;
    readonly passphrase?: Passphrase;
    readonly prompt: string;
  },
): Array<string> {
  if (options.isRoot) {
    return [command, ...args];
  }
  if (options.passphrase === SUDO_TICKET) {
    return ["sudo", "--", command, ...args];
  }
  if (typeof options.passphrase === "string") {
    return ["sudo", "-S", "-k", "-p", options.prompt, "--", command, ...args];
  }
  return [command, ...args];
}

export const stripSudoPrompt = (chunk: string, prompt: string): string => {
  return chunk.includes(prompt) ? chunk.replaceAll(prompt, "") : chunk;
};

export const writeSudoPassphrase = (
  stdin: Writable,
  passphrase: string,
): Promise<void> =>
  new Promise((resolve, reject) => {
    stdin.write(`${passphrase}\n`, (err) => {
      if (err !== undefined && err !== null) {
        reject(err);
        return;
      }
      stdin.end();
      resolve();
    });
  });

/**
 * Run a command, optionally escalating with sudo.
 * A string passphrase is written to stdin immediately for `sudo -S -k`.
 * `SUDO_TICKET` uses the cached timestamp (`sudo --`).
 */
export async function run(
  command: string,
  args: Array<string>,
  options: RunOptions = {},
): Promise<RunResult> {
  const { chdir, env, passphrase } = options;

  // Random string so we can identify sudo's password prompt in stderr without
  // matching legitimate command output.
  const prompt = `sudo[${randomBytes(16).toString("hex")}]:`;

  const final = sudoCommandLine(command, args, {
    isRoot: Deno.uid() === 0,
    ...(passphrase !== undefined ? { passphrase } : {}),
    prompt,
  });

  const zxOpts = {
    nothrow: true,
    quiet: true,
    ...(chdir ? { cwd: chdir } : {}),
    ...(env ? { env } : {}),
  };

  const p = $({ ...zxOpts })`${final}`;

  let stderrText = "";

  if (typeof passphrase === "string") {
    (p.stderr as Readable).on("data", (data: Uint8Array) => {
      stderrText += stripSudoPrompt(data.toString(), prompt);
    });
    await writeSudoPassphrase(p.stdin as Writable, passphrase);
  } else {
    (p.stderr as Readable).on("data", (data: Uint8Array) => {
      stderrText += data.toString();
    });
  }

  const result = await p;

  return {
    command: final.join(" "),
    exitCode: result.exitCode ?? 1,
    stdout: result.stdout,
    stderr: stderrText,
  };
}
