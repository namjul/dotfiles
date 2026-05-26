import { Result } from "@gordonb/result";
import type { Result as ResultType } from "@gordonb/result/result";
import path from "../path.ts";
import { getSudoPassphrase } from "../context.ts";
import { run } from "../run.ts";
import { stat } from "../stat.ts";

type CommandError = {
  type: "COMMAND_FAILED";
  command: string;
  exitCode: number;
  stdout: string;
  stderr: string;
};

type CommandResult = ResultType<
  { command: string; exitCode: number; stdout: string; stderr: string },
  CommandError
>;

export async function command(
  executable: string,
  args: Array<string>,
  options: {
    chdir?: string;
    creates?: string;
    env?: NodeJS.ProcessEnv;
    raw?: boolean;
    sudo?: boolean;
  } = {},
): Promise<CommandResult> {
  const description = [executable, ...args].join(" ");
  const cmd = path(executable.toString()).expand.toString();

  if (options.creates) {
    const s = await stat(options.creates);
    if (s !== null && !(s instanceof Error)) {
      console.debug(
        `Skip command \`${description}\` (${options.creates} exists)`,
      );
      return Result.ok({ command: cmd, exitCode: 0, stderr: "", stdout: "" });
    }
  }

  console.debug(
    `Run command \`${description}\` with options: ${JSON.stringify(options)}`,
  );

  const resolvedArgs = args.map((arg) =>
    options.raw ? arg : path(arg).expand.toString()
  );

  const r = await run(cmd, resolvedArgs, {
    ...(options.chdir ? { chdir: path(options.chdir).expand.toString() } : {}),
    ...(options.env ? { env: options.env } : {}),
    ...(options.sudo ? { passphrase: await getSudoPassphrase() } : {}),
  });

  if (r.exitCode === 0) {
    return Result.ok({
      command: cmd,
      exitCode: r.exitCode,
      stderr: r.stderr,
      stdout: r.stdout,
    });
  }
  return Result.err({
    type: "COMMAND_FAILED",
    command: cmd,
    exitCode: r.exitCode,
    stderr: r.stderr,
    stdout: r.stdout,
  });
}
