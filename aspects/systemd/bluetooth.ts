#!/usr/bin/env -S deno run --allow-all

import { assert, command, init, when } from "fig";

init(import.meta.dirname);

if (!when("arch")) Deno.exit(0);

// Enable only. Start waits for reboot (or bluetooth-power / a later start).
// Leave AutoEnable at the BlueZ default so unblocking rfkill can power the adapter.
const enable = await command("systemctl", ["enable", "bluetooth.service"], {
  sudo: true,
});
assert.result(enable);
