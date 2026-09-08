#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, path, when } from "fig";

init(import.meta.dirname);

const userFiles = [
  ".config/systemd/user/darkman.service",
  ".config/systemd/user/gammastep.service",
  ".config/systemd/user/battery-monitor.service",
  ".config/systemd/user/battery-monitor.timer",
  ".config/systemd/user/polkit-gnome-authentication-agent-1.service",
  ".config/systemd/user/udiskie.service",
  ".config/systemd/user/swayosd-server.service",
  ".config/systemd/user/niri-idle.service",
  ".config/systemd/user/swaybg.service",
  ".config/systemd/user/kanshi.service",
  ".local/bin/gammastep-session",
  ".local/bin/battery-low-warn",
];

for (const src of userFiles) {
  const r = await file({
    force: true,
    path: path.home.join(src),
    src: path.aspect.join("files", src),
    state: "link",
  });
  assert.result(r);
}

{
  const reload = await command("systemctl", ["--user", "daemon-reload"]);
  assert.result(reload);
}

const now = Deno.env.get("usage_now") === "true";

const shippedUserUnitExists = (unit: string): boolean => {
  try {
    return Deno.statSync(`/usr/lib/systemd/user/${unit}`).isFile;
  } catch {
    return false;
  }
};

const linkedUserUnitExists = (unit: string): boolean => {
  try {
    return Deno.statSync(path.home.join(".config/systemd/user", unit)).isFile;
  } catch {
    return false;
  }
};

const userUnitExists = (unit: string): boolean =>
  shippedUserUnitExists(unit) || linkedUserUnitExists(unit);

const enable = [
  "darkman.service",
  "gammastep.service",
  "gnome-keyring-daemon.socket",
];

const sharedGraphical = [
  "mako.service",
  "polkit-gnome-authentication-agent-1.service",
  "udiskie.service",
  "swayosd-server.service",
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

const enableUserUnit = async (
  service: string,
  startNow = now,
): Promise<boolean> => {
  if (!userUnitExists(service)) {
    console.warn(
      `warn: skipping ${service} (unit missing — install package or run //aspects/dotfiles:files)`,
    );
    return false;
  }
  const r = await command("systemctl", [
    "--user",
    "--no-ask-password",
    "enable",
    ...(startNow ? ["--now"] : []),
    service,
  ]);
  assert.result(r);
  return true;
};

for (const service of enable) {
  await enableUserUnit(service);
}

for (const service of sharedGraphical) {
  if (!(await enableUserUnit(service)) || !when("arch")) continue;
  const r = await command("systemctl", [
    "--user",
    "add-wants",
    "graphical-session.target",
    service,
  ]);
  assert.result(r);
}

if (when("arch")) {
  const niriCompositorUnit = "wayland-wm@niri.service";
  const niriOnly = [
    "waybar.service",
    "swaybg.service",
    "niri-idle.service",
    "kanshi.service",
  ];

  for (const service of niriOnly) {
    if (service === "waybar.service" && !shippedUserUnitExists(service)) {
      console.warn(
        "warn: skipping waybar.service (install waybar via //aspects/aur:packages)",
      );
      continue;
    }
    if (!(await enableUserUnit(service, false))) continue;

    const wantsResult = await command("systemctl", [
      "--user",
      "add-wants",
      niriCompositorUnit,
      service,
    ]);
    assert.result(wantsResult);
  }
}
