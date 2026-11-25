#!/usr/bin/env -S deno run --allow-all

import { file, init, path, stat } from "fig";
import { $ } from "zx";

init(import.meta.dirname);

const sshDir = path.home.join(".ssh").toString();
const configTarget = path.home.join(".ssh", "config").toString();
const configSource = path.aspect.join("files", ".ssh", "config").toString();
const keyFile = path.aspect.join("key.yml").toString();
const publicKeyPath = path.home.join(".ssh", "id_ed25519.pub").toString();
const privateKeyPath = path.home.join(".ssh", "id_ed25519").toString();

/** Ensure ~/.ssh exists before writing config or keys. */
async function ensureSshDir(): Promise<void> {
  const result = await file({
    mode: "0700",
    path: sshDir,
    state: "directory",
  });

  if (!result.ok) {
    throw new Error(`unable to create ${sshDir}: ${result.error.type}`);
  }
}

/** Install ~/.ssh/config by linking the aspect’s plaintext, when decrypted. */
async function installConfig(): Promise<void> {
  if ((await stat(configSource)) === null) {
    console.log("skip: .ssh/config (not decrypted; run wage decrypt)");
    return;
  }

  const result = await file({
    force: true,
    path: configTarget,
    src: configSource,
    state: "link",
  });

  if (!result.ok) {
    throw new Error(`unable to install SSH config: ${result.error.type}`);
  }
}

/** Install key material from key.yml (field extract, not fig file()). */
async function installKeys(): Promise<void> {
  await $`sops -d --extract '["public_key"]' --output ${publicKeyPath} ${keyFile}`;
  await $`sops -d --extract '["private_key"]' --output ${privateKeyPath} ${keyFile}`;
  await $`chmod 600 ${publicKeyPath} ${privateKeyPath}`;
}

/** boot.sh clones HTTPS; push needs SSH. Rewrite origin of this checkout. */
async function rewriteDotfilesGithubOrigin(): Promise<void> {
  const dest = path.root.toString();
  const got = await $`git -C ${dest} remote get-url origin`.nothrow();
  const current = got.stdout.trim();
  const match = /^https:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?\/?$/.exec(current);
  if (got.exitCode !== 0 || !match) {
    console.log(`skip github-origin: origin is ${current || "missing"}`);
    return;
  }

  const next = `git@github.com:${match[1]}/${match[2]}.git`;
  await $`git -C ${dest} remote set-url origin ${next}`;
  console.log(`origin ${current} → ${next}`);
}

if (import.meta.main) {
  const sub = Deno.args[0];
  if (sub === "dir") {
    await ensureSshDir();
  } else if (sub === "config") {
    await installConfig();
  } else if (sub === "keys") {
    await installKeys();
  } else if (sub === "github-origin") {
    await rewriteDotfilesGithubOrigin();
  } else {
    Deno.exit(1);
  }
}
