import { getSudoPassphrase } from "../context.ts";
import { run } from "../run.ts";

type Options = {
  sudo?: boolean;
};

export async function cp(
  src: string,
  dest: string,
  options: Options = {},
): Promise<Error | null> {
  const passphrase = options.sudo ? await getSudoPassphrase() : undefined;

  const r = await run(
    "cp",
    [src, dest],
    passphrase !== undefined ? { passphrase } : {},
  );

  if (r.exitCode === 0) {
    return null;
  }

  return new Error(
    r.stderr || `cp ${src} ${dest} failed with exit code ${r.exitCode}`,
  );
}
