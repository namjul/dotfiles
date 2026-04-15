#!/usr/bin/env -S deno run --allow-all

import { file, init, path } from "fig";
import { $ } from "zx";

init(import.meta.dirname);

const sshDir = path.home.join(".ssh").toString();
const configTarget = path.home.join(".ssh", "config").toString();
const encryptedConfigSource = path.aspect.join("files", ".ssh", "config.encrypted").toString();
const keyFile = path.aspect.join("key.yml").toString();
const publicKeyPath = path.home.join(".ssh", "id_rsa.pub").toString();
const privateKeyPath = path.home.join(".ssh", "id_rsa").toString();

if (import.meta.main) {
  const sub = Deno.args[0];
  if (sub === "dir") {
    await ensureSshDir();
  } else if (sub === "config") {
    await installConfig();
  } else if (sub === "keys") {
    await installKeys();
  } else {
    Deno.exit(1);
  }
}

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
