---
name: new-aspect
description: Scaffold a new aspect (configuration unit) in a mise-based dotfiles monorepo with the fig/Deno framework. Use when user wants to create a new aspect, add a config unit, or scaffold a new dotfiles module.
---

# New Aspect

## Quick start

Minimal structure:

```
aspects/<name>/
└── mise.toml
```

```toml
[tasks.default]
run = ""
```

## Workflow

1. Create `aspects/<name>/` folder
2. Add `mise.toml` with at least `[tasks.default]`
3. If aspect manages files via fig: add Deno script, mark executable

## Fig script

```ts
#!/usr/bin/env -S deno run --allow-all

import { assert, file, init, path, variable, variables } from "fig";

await init(import.meta.dirname);
```

```sh
chmod +x aspects/<name>/index.ts
```

Point to it from mise.toml (paths relative to mise.toml):

```toml
[tasks.default]
run = "./index.ts"
```

## Rules

- Import fig via bare specifier `from "fig"` (mapped in root `deno.json`)
- `init(import.meta.dirname)` must run before any other fig operations
- `index.ts` must be executable (`chmod +x`)
- Tasks: inline (`run = "shell cmd"`) or external file, paths relative
