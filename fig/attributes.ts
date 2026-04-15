import { os } from "zx";

/**
 * System attributes - detected from the environment
 */
export const attributes = {
  platform: os.platform(),
  hostname: os.hostname(),
  home: os.homedir(),
  user: os.userInfo().username,
};

export type Attributes = typeof attributes;
