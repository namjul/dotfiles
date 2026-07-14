---
name: manage-aspects
description: Use when adding, strengthening, dissolving, or managing aspects in this dotfiles repo with the fig framework. Triggers on "add aspect", "new aspect", "strengthen aspect", "manage aspects" or any aspect management task.
---


# Minimal aspect structure

```
aspects/<name>/
└── mise.toml
```

```toml
[tasks.default]
run = ""
```

# Fig framework

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
