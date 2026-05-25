import { init, when } from "fig";

init(import.meta.dirname);

async function run(script: string): Promise<void> {
  const proc = new Deno.Command("bash", {
    args: [`${import.meta.dirname!}/${script}`],
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  }).spawn();
  const status = await proc.status;
  if (!status.success) Deno.exit(status.code);
}

if (import.meta.main) {
  if (!when("arch")) {
    Deno.exit(0);
  }
  await run("preflight");
  await run("packages");
  await run("firewall");
}
