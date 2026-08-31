#!/usr/bin/env -S deno run --allow-all

import { file, init, path } from "fig";
import { $ } from "zx";

init(import.meta.dirname);

const sshDir = path.home.join(".ssh").toString();
const configTarget = path.home.join(".ssh", "config").toString();
const encryptedConfigSource = path.aspect.join("files", ".ssh", "config.encrypted").toString();
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

/** Install ~/.ssh/config from the aspect’s encrypted file (whole-file SOPS decrypt). */
async function installConfig(): Promise<void> {
  const result = await file({
    mode: "600",
    path: configTarget,
    src: encryptedConfigSource,
    state: "encrypted",
    force: true,
  });

  if (result.ok) {
    console.log("decrypted .ssh/config.encrypted -> .ssh/config");
  } else if (result.error.type === "TARGET_EXISTS") {
    console.warn(".ssh/config already exists. Won't change.");
  } else {
    throw new Error(`unable to install SSH config (encrypted): ${result.error.type}`);
  }
}

/** Install key material from key.yml (field extract, not fig file()). */
async function installKeys(): Promise<void> {
  await $`sops -d --extract '["public_key"]' --output ${publicKeyPath} ${keyFile}`;
  await $`sops -d --extract '["private_key"]' --output ${privateKeyPath} ${keyFile}`;
  await $`chmod 600 ${publicKeyPath} ${privateKeyPath}`;
}

/** Map a GitHub HTTPS remote to SSH. Other URLs stay unchanged (undefined). */
export const githubHttpsToSsh = (url: string): string | undefined => {
  const match = /^https:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?\/?$/.exec(url.trim());
  if (!match) {
    return undefined;
  }
  return `git@github.com:${match[1]}/${match[2]}.git`;
};

/** boot.sh clones HTTPS; push needs SSH. Only rewrite ~/.dotfiles origin. */
async function rewriteDotfilesGithubOrigin(): Promise<void> {
  const dest = path.home.join(".dotfiles").toString();
  const gitDir = path.home.join(".dotfiles", ".git").toString();
  try {
    await Deno.stat(gitDir);
  } catch {
    console.log(`skip github-origin: ${dest} is not a git clone`);
    return;
  }

  const current = (await $`git -C ${dest} remote get-url origin`.nothrow()).stdout.trim();
  if (current === "") {
    console.log(`skip github-origin: no origin in ${dest}`);
    return;
  }

  const next = githubHttpsToSsh(current);
  if (!next) {
    console.log(`skip github-origin: origin is already ${current}`);
    return;
  }

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
