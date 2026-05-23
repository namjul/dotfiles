#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, path, stat } from "fig";

init(import.meta.dirname);

const configs = ["dual-function-keys.yaml", "udevmon.yaml"];

for (const config of configs) {
  const r = await file({
    force: true,
    path: `/etc/interception/${config}`,
    src: path.aspect.join("files", config),
    state: "copy",
    sudo: true,
  });
  assert.result(r);
}

const systemd = await stat("/run/systemd/system");
if (systemd === null || systemd instanceof Error) {
  console.warn("systemd not available, skipping service management");
  Deno.exit(0);
}

const enable = await command("systemctl", ["enable", "--now", "udevmon"], { sudo: true });
assert.result(enable);

const reload = await command("udevadm", ["control", "--reload"], { sudo: true });
assert.result(reload);
