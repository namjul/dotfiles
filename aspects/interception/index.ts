#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, when, path } from "fig";

init(import.meta.dirname);

if (!when("linux")) Deno.exit(0);

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

const enable = await command("systemctl", ["enable", "--now", "udevmon"], { sudo: true });
assert.result(enable);

const reload = await command("udevadm", ["control", "--reload"], { sudo: true });
assert.result(reload);
