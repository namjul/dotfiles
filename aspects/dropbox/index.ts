#!/usr/bin/env -S deno run --allow-all

import { assert, command, init, path, when } from "fig";

init(import.meta.dirname);

const validPgpKeysFromPkgbuild = (text: string): ReadonlyArray<string> => {
  const block = /validpgpkeys=\(([\s\S]*?)\)/.exec(text)?.[1];
  if (block === undefined) return [];
  return [...block.matchAll(/['"]([0-9A-Fa-f]{40})['"]/g)].flatMap((m) => {
    const fingerprint = m[1];
    return fingerprint === undefined ? [] : [fingerprint];
  });
};

const pkgbuildVersion = (text: string): string | undefined => {
  const ver = /^pkgver=(.+)$/m.exec(text)?.[1]?.trim();
  const rel = /^pkgrel=(.+)$/m.exec(text)?.[1]?.trim();
  if (ver === undefined || rel === undefined) return undefined;
  return `${ver}-${rel}`;
};

const pacmanQueryVersion = (stdout: string): string | undefined => {
  const match = /^\S+\s+(\S+)/.exec(stdout.trim());
  return match?.[1];
};

if (!when("arch")) {
  console.log("dropbox aspect: skip (not Arch)");
  Deno.exit(0);
}

const upgrade = Deno.env.get("usage_upgrade") === "true";

const deps = await command("pacman", [
  "-S",
  "--needed",
  "--noconfirm",
  "base-devel",
  "git",
  "python-gpgme",
  "libappindicator",
], { sudo: true });
assert.result(deps);

const cache = Deno.env.get("XDG_CACHE_HOME") ?? path.home.join(".cache").toString();
const src = path(cache).join("dropbox-aur").toString();

const hasGit = await Deno.stat(`${src}/.git`).then(() => true).catch(() => false);
if (hasGit) {
  const pull = await command("git", ["-C", src, "pull", "--ff-only"]);
  assert.result(pull);
} else {
  const removeSrc = await command("rm", ["-rf", src]);
  assert.result(removeSrc);
  const clone = await command("git", [
    "clone",
    "https://aur.archlinux.org/dropbox.git",
    src,
  ], { raw: true });
  assert.result(clone);
}

const pkgbuild = await Deno.readTextFile(path(src).join("PKGBUILD").toString());
const aurVersion = pkgbuildVersion(pkgbuild);
if (aurVersion === undefined) {
  console.error("dropbox aspect: PKGBUILD missing pkgver/pkgrel");
  Deno.exit(1);
}

const installed = await command("pacman", ["-Q", "dropbox"]);
const localVersion = installed.ok
  ? pacmanQueryVersion(installed.value.stdout)
  : undefined;

const buildPackage = async (): Promise<void> => {
  const fingerprints = validPgpKeysFromPkgbuild(pkgbuild);
  if (fingerprints.length === 0) {
    console.error("dropbox aspect: no validpgpkeys in PKGBUILD");
    Deno.exit(1);
  }

  const recvKey = await command("gpg", [
    "--keyserver",
    "hkps://keyserver.ubuntu.com",
    "--recv-keys",
    ...fingerprints,
  ], { raw: true });
  assert.result(recvKey);

  const build = await command("makepkg", ["-si", "--noconfirm", "--needed"], {
    chdir: src,
  });
  assert.result(build);
};

if (localVersion === undefined) {
  await buildPackage();
} else if (upgrade) {
  console.log(`dropbox ${localVersion} installed; AUR is ${aurVersion} — rebuilding`);
  await buildPackage();
} else if (localVersion === aurVersion) {
  console.log(`dropbox ${localVersion} matches AUR — skip makepkg`);
} else {
  console.log(
    `dropbox ${localVersion} installed; AUR is ${aurVersion} — run with --upgrade`,
  );
}

const dist = path.home.join(".dropbox-dist").toString();

const distLocked = async (): Promise<boolean> => {
  try {
    const s = await Deno.stat(dist);
    return s.isDirectory && ((s.mode ?? 0) & 0o777) === 0;
  } catch {
    return false;
  }
};

if (!(await distLocked())) {
  // Official client downloads updates into ~/.dropbox-dist and hands off to that
  // binary, then exits. systemd restarts dropbox.service, which fights the new
  // process — restart loop, CPU, and journal spam.
  // https://wiki.archlinux.org/title/Dropbox#Prevent_automatic_updates
  const remove = await command("rm", ["-rf", dist]);
  assert.result(remove);
  // -d: create directory; -m0: mode 000 so Dropbox cannot write the update tree.
  const lock = await command("install", ["-dm0", dist]);
  assert.result(lock);
}

// Package install just dropped usr/lib/systemd/user/dropbox.service; reload so
// enable resolves that unit. No --now: first start needs a graphical login.
const reload = await command("systemctl", ["--user", "daemon-reload"]);
assert.result(reload);

const enable = await command("systemctl", ["--user", "enable", "dropbox.service"]);
assert.result(enable);
