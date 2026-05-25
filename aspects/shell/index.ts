#!/usr/bin/env -S deno run --allow-all

import { assert, attributes, command, file, init } from "fig";

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

const dataDir = Deno.env.get("DATA_DIR");
const dataBackup = Deno.env.get("DATA_BACKUP");

if (dataDir && dataBackup) {
  const fishHistory = `${Deno.env.get("HOME")}/.local/share/fish/fish_history`;
  const timestamp = `${dataBackup}/fish-history.${new Date().toISOString().replace(/[:.]/g, "-")}`;

  await command("mkdir", ["-p", `${Deno.env.get("HOME")}/.local/share/fish`, dataBackup]);

  let stat: Deno.FileInfo | null = null;
  try { stat = await Deno.lstat(fishHistory); } catch { /* not found */ }

  if (stat && !stat.isSymlink) {
    const mv = await command("mv", [fishHistory, timestamp]);
    assert.result(mv);
  }

  let linkStat: Deno.FileInfo | null = null;
  try { linkStat = await Deno.lstat(fishHistory); } catch { /* not found */ }

  if (!linkStat?.isSymlink) {
    const r = await file({
      force: true,
      path: fishHistory,
      src: `${dataDir}/fish_history`,
      state: "link",
    });
    assert.result(r);

    if (stat) {
      const cat = await command("bash", ["-c", `cat '${timestamp}' > '${dataDir}/fish_history'`]);
      assert.result(cat);
    }
  }
}
