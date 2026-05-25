import { os } from "zx";

function existsSync(path: string): boolean {
  try {
    Deno.statSync(path);
    return true;
  } catch {
    return false;
  }
}

function detectDistribution(): "arch" | "debian" | "" {
  if (existsSync("/etc/arch-release")) return "arch";
  if (existsSync("/etc/debian_version")) return "debian";
  return "";
}

export interface Attributes {
  platform: string;
  distribution: "arch" | "debian" | "";
  hostname: string;
  home: string;
  username: string;
}

export const attributes: Attributes = {
  platform: os.platform(),
  distribution: detectDistribution(),
  hostname: os.hostname(),
  home: os.homedir(),
  username: os.userInfo().username,
};
