#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, path, when } from "fig";

init(import.meta.dirname);

if (!when("arch")) Deno.exit(0);

const hasBattery = (): boolean => {
  try {
    for (const entry of Deno.readDirSync("/sys/class/power_supply")) {
      try {
        const kind = Deno.readTextFileSync(
          `/sys/class/power_supply/${entry.name}/type`,
        ).trim();
        if (kind === "Battery") return true;
      } catch {
        // missing type file
      }
    }
  } catch {
    // no power_supply class
  }
  return false;
};

if (!hasBattery()) {
  console.log("no battery, skipping");
  Deno.exit(0);
}

const enable = await command("systemctl", [
  "enable",
  "--now",
  "power-profiles-daemon",
], { sudo: true });
assert.result(enable);

const rulesDir = await file({
  path: "/etc/udev/rules.d",
  state: "directory",
  sudo: true,
});
assert.result(rulesDir);

const rules = await file({
  force: true,
  path: "/etc/udev/rules.d/99-power-profile.rules",
  src: path.aspect.join("files/etc/udev/rules.d/99-power-profile.rules"),
  state: "copy",
  sudo: true,
});
assert.result(rules);

const reload = await command("udevadm", ["control", "--reload"], {
  sudo: true,
});
assert.result(reload);

const trigger = await command("udevadm", ["trigger"], { sudo: true });
assert.result(trigger);
