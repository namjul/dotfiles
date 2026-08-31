import { assertEquals } from "@std/assert";
import { resolveSudoAskpass, SUDO_TICKET, sudoCommandLine } from "./run.ts";

Deno.test("sudoCommandLine: no passphrase leaves the command unchanged", () => {
  assertEquals(sudoCommandLine("mkdir", ["-p", "/tmp/x"], {
    isRoot: false,
    prompt: "sudo[x]:",
  }), ["mkdir", "-p", "/tmp/x"]);
});

Deno.test("sudoCommandLine: root never prefixes sudo", () => {
  assertEquals(sudoCommandLine("mkdir", ["-p", "/etc/x"], {
    isRoot: true,
    passphrase: "secret",
    prompt: "sudo[x]:",
  }), ["mkdir", "-p", "/etc/x"]);
});

Deno.test("sudoCommandLine: passphrase uses sudo -S -k", () => {
  assertEquals(sudoCommandLine("chsh", ["-s", "/bin/fish"], {
    isRoot: false,
    passphrase: "secret",
    prompt: "sudo[x]:",
  }), ["sudo", "-S", "-k", "-p", "sudo[x]:", "--", "chsh", "-s", "/bin/fish"]);
});

Deno.test("sudoCommandLine: cached sudo uses the timestamp", () => {
  assertEquals(sudoCommandLine("chsh", ["-s", "/bin/fish"], {
    isRoot: false,
    passphrase: SUDO_TICKET,
    prompt: "sudo[x]:",
  }), ["sudo", "--", "chsh", "-s", "/bin/fish"]);
});

Deno.test("resolveSudoAskpass: keeps an explicit SUDO_ASKPASS", () => {
  assertEquals(resolveSudoAskpass({
    sudoAskpass: "/custom/askpass",
    waylandDisplay: undefined,
    display: undefined,
    helperOnPath: false,
    defaultHelper: "/repo/bin/fig-sudo-askpass",
  }), "/custom/askpass");
});

Deno.test("resolveSudoAskpass: default helper when wofi and a display exist", () => {
  assertEquals(resolveSudoAskpass({
    sudoAskpass: undefined,
    waylandDisplay: "wayland-1",
    display: undefined,
    helperOnPath: true,
    defaultHelper: "/repo/bin/fig-sudo-askpass",
  }), "/repo/bin/fig-sudo-askpass");
});

Deno.test("resolveSudoAskpass: unset without display or helper", () => {
  assertEquals(resolveSudoAskpass({
    sudoAskpass: undefined,
    waylandDisplay: undefined,
    display: undefined,
    helperOnPath: true,
    defaultHelper: "/repo/bin/fig-sudo-askpass",
  }), undefined);
  assertEquals(resolveSudoAskpass({
    sudoAskpass: undefined,
    waylandDisplay: "wayland-1",
    display: undefined,
    helperOnPath: false,
    defaultHelper: "/repo/bin/fig-sudo-askpass",
  }), undefined);
});
