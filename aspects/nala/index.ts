import { init, when } from "fig";

init(import.meta.dirname);

if (import.meta.main) {
  if (!when("debian")) {
    Deno.exit(0);
  }
  const proc = new Deno.Command("bash", {
    args: [`${import.meta.dirname!}/packages`],
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  }).spawn();
  const status = await proc.status;
  if (!status.success) Deno.exit(status.code);
}
