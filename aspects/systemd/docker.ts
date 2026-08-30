#!/usr/bin/env -S deno run --allow-all

import { assert, command, init, when } from "fig";

init(import.meta.dirname);

if (!when("arch")) Deno.exit(0);

const enable = await command("systemctl", ["enable", "--now", "docker.socket"], {
  sudo: true,
});
assert.result(enable);
