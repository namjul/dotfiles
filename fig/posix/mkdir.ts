import { getSudoPassphrase } from "../context.ts";
import { run } from "../run.ts";

type Options = {
  parents?: boolean;
  sudo?: boolean;
};

export async function mkdir(
  path: string,
  options: Options = {},
): Promise<Error | null> {
  const args = options.parents ? ["-p", path] : [path];
  const passphrase = options.sudo ? await getSudoPassphrase() : undefined;

  const r = await run(
    "mkdir",
    args,
    passphrase !== undefined ? { passphrase } : {},
  );

  if (r.exitCode === 0) {
    return null;
  }

  return new Error(
    r.stderr || `mkdir ${args.join(" ")} failed with exit code ${r.exitCode}`,
  );
}
