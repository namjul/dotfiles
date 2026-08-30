#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, path } from "fig";

init(import.meta.dirname);

const userServices = [
  ".config/systemd/user/darkman.service",
  ".config/systemd/user/redshift.service",
  ".config/systemd/user/battery-monitor.service",
  ".config/systemd/user/battery-monitor.timer",
];

for (const src of userServices) {
  const r = await file({
    force: true,
    path: path.home.join(src),
    src: path.aspect.join("files", src),
    state: "link",
  });
  assert.result(r);
}

{
  const r = await file({
    force: true,
    path: path.home.join(".local/bin/battery-low-warn"),
    src: path.root.join("bin/battery-low-warn"),
    state: "link",
  });
  assert.result(r);
}

{
  const reload = await command("systemctl", ["--user", "daemon-reload"]);
  assert.result(reload);
}

const now = Deno.env.get("usage_now") === "true";

const enable = [
  "darkman.service",
  "redshift.service",
  "gnome-keyring-daemon.socket",
];

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

if (hasBattery()) {
  enable.push("battery-monitor.timer");
} else {
  console.log("no battery, skipping battery-monitor.timer");
}

for (const service of enable) {
  const args = [
    "--user",
    "--no-ask-password",
    "enable",
    ...(now ? ["--now"] : []),
    service,
  ];
  const r = await command("systemctl", args);
  assert.result(r);
}
