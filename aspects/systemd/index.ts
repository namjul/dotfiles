#!/usr/bin/env -S deno run --allow-all

import { assert, command, file, init, path } from "fig";

init(import.meta.dirname);

const userServices = [
  ".config/systemd/user/ssh-agent.service",
  ".config/systemd/user/darkman.service",
  ".config/systemd/user/redshift.service",
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

const reload = await command("systemctl", ["--user", "daemon-reload"]);
assert.result(reload);

const now = Deno.env.get("usage_now") === "true";

for (const service of ["ssh-agent.service", "darkman.service", "redshift.service"]) {
  const args = ["--user", "enable", ...(now ? ["--now"] : []), service];
  const r = await command("systemctl", args);
  assert.result(r);
}

