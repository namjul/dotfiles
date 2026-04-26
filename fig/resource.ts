import path from "./path.ts";
import { Path } from "./types.ts";

export function file(...components: Array<string>): Path {
  return resource("files", ...components);
}
function resource(subdirectory: string, ...components: Array<string>): Path {
  return path.aspect.join(subdirectory, ...components);
}
