import { Result } from "@gordonb/result";
import type { Result as ResultType } from "@gordonb/result/result";
import type { Option } from "@gordonb/result/option";
import { $, ProcessOutput } from "zx";
import { path } from "../path.ts";

type CustomProcessOutput = Pick<
  ProcessOutput,
  "exitCode" | "stdout" | "stderr"
>;
type CommandError =
  & { type: "COMMAND_FAILED"; command: string }
  & CustomProcessOutput;
type CommandResult = ResultType<
  { command: string } & CustomProcessOutput,
  CommandError
>;

export async function command(
  executable: string,
  args: Array<string>,
  options: {
    chdir?: Option<string>;
    env?: Option<NodeJS.ProcessEnv>;
    raw?: boolean;
  } = {},
): Promise<CommandResult> {
  const description = [executable, ...args].join(" ");
  const command = path(executable.toString()).expand.toString();

  console.debug(
    `Run command \`${description}\` with options: ${JSON.stringify(options)}`,
  );

  const { exitCode, stderr, stdout } = await $({
    nothrow: true,
    ...(options.chdir ? { cwd: path(options.chdir).expand.toString() } : {}),
    ...(options.env ? { env: options.env } : {}),
  })`${command} ${
    args.map((arg) => (options.raw ? arg : path(arg).expand.toString()))
  }`;

  if (exitCode === 0) {
    return Result.ok({
      command,
      exitCode,
      stderr,
      stdout,
    });
  }
  return Result.err({
    type: "COMMAND_FAILED",
    command,
    exitCode,
    stderr,
    stdout,
  });
}
