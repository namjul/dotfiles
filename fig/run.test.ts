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

Deno.test("resolveSudoAskpass: keeps a non-empty SUDO_ASKPASS", () => {
  assertEquals(resolveSudoAskpass("/custom/askpass"), "/custom/askpass");
});

Deno.test("resolveSudoAskpass: unset or empty is undefined", () => {
  assertEquals(resolveSudoAskpass(undefined), undefined);
  assertEquals(resolveSudoAskpass(""), undefined);
});
