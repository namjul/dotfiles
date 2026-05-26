
## Repository Overview

This is a personal dotfiles and system management system using **mise** as the task orchestrator and **fig** as a custom Deno-based configuration framework. The repository manages system aspects (shell, nvim, SSH, fonts, etc.)

Key features:
- **Mise-based monorepo**: Each aspect is a self-contained configuration unit with its own `mise.toml`
- **Fig framework**: Custom Deno library for idempotent file management (symlinks, hardlinks, encrypted files, templates)
- **Encryption**: Sensitive files (SSH configs, keys, environment variables) encrypted with age
- **Server provisioning**: Remote server setup via mise tasks in the `server` aspect

## Making commits

This project uses **Living Systems Commits** - a protocol that treats software as living structure, not mechanical assembly.

### Format

- Start the subject line with a type prefix: `strengthen`, `create`, `dissolve`, `revision`, `simplify`, `refactor`, `chore`, `unfolding`, `repair`
- Optionally scope the prefix (e.g., `refactor(fig):`, `repair(nvim):`); if the changes affect a single aspect, use the aspect name as the scope.


## Mise tasks

Mise tasks that accept arguments MUST declare them with the `usage` field using mise's task argument syntax (https://mise.jdx.dev/tasks/task-arguments.html). Never use bare `$1`/`$2` positional parameters. Arguments are accessed as `${usage_<name>?}` in the run script.

```toml
[tasks.example]
usage = 'arg "<file>" help="File to process"'
run = 'process "${usage_file?}"'
```

## Markdown

When writing Markdown, do not hard-wrap long lines.
