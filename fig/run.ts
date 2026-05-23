import { randomBytes } from "node:crypto";
import type { Readable, Writable } from "node:stream";
import { $ } from "zx";

type RunOptions = {
  chdir?: string;
  env?: NodeJS.ProcessEnv;
  passphrase?: string;
};

export type RunResult = {
  command: string;
  exitCode: number;
  stdout: string;
  stderr: string;
};

/**
 * Run a command, optionally escalating with sudo when a passphrase is provided.
 * Passphrase is injected via stdin only when sudo emits the prompt on stderr,
 * matching wincent's event-driven approach.
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

  const final = passphrase !== undefined
    ? ["sudo", "-S", "-k", "-p", prompt, "--", command, ...args]
    : [command, ...args];

  const zxOpts = {
    nothrow: true,
    quiet: true,
    ...(chdir ? { cwd: chdir } : {}),
    ...(env ? { env } : {}),
  };

  const p = $({ ...zxOpts })`${final}`;

  let stderrText = "";

  if (passphrase !== undefined) {
    // Attach before awaiting so we catch every stderr chunk as it arrives.
    // sudo -S reads stdin synchronously, so a timing race is unlikely, but
    // writing only in response to the prompt is more correct than stuffing
    // stdin unconditionally upfront.
    (p.stderr as Readable).on("data", (data: Uint8Array) => {
      const chunk = data.toString();
      if (chunk === prompt) {
        // sudo is asking for the password — write once and close. Closing
        // stdin prevents sudo from retrying on a wrong passphrase.
        (p.stdin as Writable).write(`${passphrase}\n`);
        (p.stdin as Writable).end();
      } else {
        stderrText += chunk;
      }
    });
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
