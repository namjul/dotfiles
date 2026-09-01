#!/usr/bin/env -S deno run --allow-all

import { assert, attributes, command, init } from "fig";

init(import.meta.dirname);

const which = await command("which", ["fish"]);

if (!which.ok) {
  console.warn("warn: fish not found in PATH, skipping");
  Deno.exit(0);
}

const fishPath = which.value.stdout.trim();

const shells = await Deno.readTextFile("/etc/shells");
if (!shells.includes(fishPath)) {
  const add = await command("bash", ["-c", `echo '${fishPath}' | tee -a /etc/shells`], { sudo: true });
  assert.result(add);
}


const chsh = await command("chsh", ["-s", fishPath, attributes.username], { sudo: true });
assert.result(chsh);
