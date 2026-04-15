/**
 * Repository-wide hardening tasks for meta aspect.
 */
import { root, file, Result } from "fig";

// Intentionally harden the entire dotfiles repository directory.
const result = await file({
  mode: "0700",
  path: root,
  state: "directory",
});

if (Result.isErr(result)) {
  throw new Error(`cannot secure repository permissions for ${root}: ${result.error.type}`);
}

console.log(`5. Secured repository permissions via fig file() at ${root} (0700)`);
