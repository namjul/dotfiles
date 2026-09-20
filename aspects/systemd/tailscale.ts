#!/usr/bin/env -S deno run --allow-all

import { assert, command, init, when } from "fig";

init(import.meta.dirname);

if (!when("arch")) Deno.exit(0);

// Enable daemon only. Join the tailnet once with: tailscale up (browser login).
const enable = await command("systemctl", ["enable", "--now", "tailscaled.service"], {
  sudo: true,
});
assert.result(enable);
