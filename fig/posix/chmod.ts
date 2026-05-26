import { getSudoPassphrase } from "../context.ts";
import { run } from "../run.ts";

type Options = {
  sudo?: boolean;
};

export async function chmod(
  mode: string,
  path: string,
  options: Options = {},
): Promise<Error | null> {
  const passphrase = options.sudo ? await getSudoPassphrase() : undefined;

  const r = await run(
    "chmod",
    [mode, path],
    passphrase !== undefined ? { passphrase } : {},
  );

  if (r.exitCode === 0) {
    return null;
  }

  return new Error(
    r.stderr || `chmod ${mode} ${path} failed with exit code ${r.exitCode}`,
  );
}
