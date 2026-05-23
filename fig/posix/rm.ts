import { getSudoPassphrase } from "../context.ts";
import { run } from "../run.ts";

type Options = {
  recurse?: boolean;
  sudo?: boolean;
};

export async function rm(path: string, options: Options = {}): Promise<Error | null> {
  const args = ["-f", path];

  if (options.recurse) {
    args.unshift("-r");
  }

  const passphrase = options.sudo ? await getSudoPassphrase() : undefined;

  const r = await run("rm", args, passphrase !== undefined ? { passphrase } : {});

  if (r.exitCode === 0) {
    return null;
  }

  return new Error(r.stderr || `rm ${args.join(" ")} failed with exit code ${r.exitCode}`);
}
