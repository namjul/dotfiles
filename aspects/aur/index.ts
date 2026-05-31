import { assert, file, init, path, when } from "fig";

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

  const keyringsDir = path.home.join(".local/share/keyrings");
  assert.result(await file({ path: keyringsDir, state: "directory", mode: "0700" }));

  for (const [name, mode] of [
    ["Default_keyring.keyring", "0600"],
    ["default", "0644"],
  ] as const) {
    const r = await file({
      path: keyringsDir.join(name),
      src: path.aspect.join("files/.local/share/keyrings", name),
      state: "copy",
      mode,
    });
    if (!r.ok && r.error.type !== "TARGET_EXISTS") assert.result(r);
  }
}
