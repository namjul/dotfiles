import { os } from "zx";

/**
 * System attributes - detected from the environment
 */
export interface Attributes {
  platform: string;
  hostname: string;
  home: string;
  user: string;
}

export const attributes: Attributes = {
  platform: os.platform(),
  hostname: os.hostname(),
  home: os.homedir(),
  user: os.userInfo().username,
};
