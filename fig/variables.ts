import { registerVariablesCallback } from "./context.ts";
import { type Variables } from "./types.ts";

export function variables(callback: (v: Variables) => Variables): void {
  registerVariablesCallback(callback);
}
