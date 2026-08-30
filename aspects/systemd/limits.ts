#!/usr/bin/env -S deno run --allow-all

import { assert, file, init, path, when } from "fig";

init(import.meta.dirname);

if (!when("arch")) Deno.exit(0);

const src = path.aspect.join("files/etc/systemd/system.conf.d/99-nofile.conf");

for (const dest of [
  "/etc/systemd/system.conf.d/99-nofile.conf",
  "/etc/systemd/user.conf.d/99-nofile.conf",
]) {
  const dir = await file({
    path: dest.replace(/\/[^/]+$/, ""),
    state: "directory",
    sudo: true,
  });
  assert.result(dir);

  const conf = await file({
    force: true,
    path: dest,
    src,
    state: "copy",
    sudo: true,
  });
  assert.result(conf);
}
