
## Repository Overview

This is a personal dotfiles and system management system using **mise** as the task orchestrator and **fig** as a custom Deno-based configuration framework. The repository manages system aspects (shell, nvim, SSH, fonts, etc.)

Key features:
- **Mise-based monorepo**: Each aspect is a self-contained configuration unit with its own `mise.toml`
- **Fig framework**: Custom Deno library for idempotent file management (symlinks, hardlinks, encrypted files, templates)
- **Encryption**: Sensitive files (SSH configs, keys, environment variables) encrypted with age
- **Server provisioning**: Remote server setup via mise tasks in the `server` aspect

## Aspects
- `aur` — Verify environment and prepare pacman (Arch)
- `dotfiles` — Symlink dotfiles from repo into $HOME
- `fonts` — Install JetBrains Mono font files
- `homebrew` — Update Homebrew packages
- `i3status-rust` — i3status-rust bar configuration
- `interception` — Interception Tools key remapping
- `meta` — @fig/ framework global operations and verification
- `nala` — Install and update packages via nala (Ubuntu)
- `nvim` — Neovim configuration
- `proxy` — Deno Deploy CORS proxy
- `server` — Remote VPS provisioning (hobl.at)
- `shell` — Set user shell to fish
- `ssh` — SSH config and key management (encrypted)
- `systemd` — systemd user unit management

## Routing
| Task | Aspect | Read |
|------|--------|------|
| Dotfiles symlinks, $HOME structure | `dotfiles` | aspects/dotfiles/CONTEXT.md |
| Neovim config | `nvim` | aspects/nvim/CONTEXT.md |
| Remote VPS / server services | `server` | aspects/server/CONTEXT.md |


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

## Typescript

## The Character of Code

```
| Idea | Name | Pattern (Context → Conflicting Forces → Configuration) | Rationale |
|------|------|----------------------------------------------------------|-----------|
| Pragmatic functional style | A Normal Kind of Function | When writing code → desire for elegance vs need for readability in multi-paradigm languages → Write normal-looking functional code | Avoids overly-fancy patterns that don't translate well |
| Prefer pure functions over classes | Pure Work | When designing abstractions → OOP elegance vs testability and predictability → Use functions and data unless API demands class | Pure functions are easier to test, reason about, and compose |
| Classes ok when API wants them | The Shape That Fits | When integrating with external APIs → personal preference vs interoperability → Use class if the API requires it | Pragmatic - work with the tool, not against it |
| Avoid currying/point-free style | A Clear Path | When writing functions → elegance of functional composition vs readability/maintainability → Write explicit arguments | These patterns don't work well in multi-paradigm languages |
| Factor out pure functions | A Reusable Gesture | When seeing repeated logic → inline vs extracted → Extract common logic into reusable pure functions | Enables reuse and separates concerns |
| Functional core, imperative shell | A Quiet Center | When structuring application → pure logic vs IO/side-effects → Core is pure, shell handles effects | Minimizes unpredictable behavior |
```

## The Grammar of Form

```
| Idea | Name | Pattern (Context → Conflicting Forces → Configuration) | Rationale |
|------|------|----------------------------------------------------------|-----------|
| Arrow functions over function declarations | A Bound Work | When declaring functions → hoisting flexibility vs top-down organization → Use arrow functions with const | No hoisting enforces better code organization |
| Include return type in function declaration | A Known Shape | When defining functions → inference flexibility vs explicit contracts → Explicitly type return | Makes contract clear to callers |
| Prefer interface over type | A Named Contract | When defining types → type flexibility vs tooling → Use interface | Interfaces appear by name in errors and tooltips |
| Type only for unions/utilities | A Union of Shapes | When not using interface → need for union/mapped types vs interface capability → Use type for unions, mapped types, tuples | Types needed for these features |
| Uppercase namespace imports | A Strong Name | When using namespace imports → lowercase vs uppercase → Use Module uppercase convention | Convention for clarity and consistency |
| Import with file extension (Deno/web) | A Full Address | When importing in Deno/browser → bare imports vs file extensions → Include extension ./module.ts | Required for these environments |
| type keyword for type imports | A Clear Kind | When importing types → mixed vs explicit → Use import { type Foo } | Clear distinction between type and value imports |
| Export at point of definition | A Thing Exposed Where It Lives | When defining exports → centralized vs distributed → Export where defined | Better readability and discoverability |
| Prefer map/filter/reduce | A Gentle Transformation | When transforming arrays immutably → mutation vs transformation → Use map/filter/reduce | Immutable array operations |
| Prefer for-of over forEach | A Simple Walk | When transforming arrays mutably → forEach vs for-of → Use for-of | More readable for mutable operations |
| Prefer undefined to null | An Empty Nothing | When representing optionality → null vs undefined → Use undefined | Simpler handling of optional values |
| Native #field syntax | A True Privacy | When declaring private fields → TypeScript private vs native → Use #field | Native syntax is enforced at runtime |
| Arrow function class fields | A Bound Self | When needing bound methods → bind manually vs class field arrow → Use method = () => {} | Hard-bound this without manual binding |
```

## The Shape of Modules

```
| Idea | Name | Pattern (Context → Conflicting Forces → Configuration) | Rationale |
|------|------|----------------------------------------------------------|-----------|
| Top-down readability | A Whole Before Its Parts | When organizing code → bottom-up implementation vs top-down reading → Public API first (interfaces/types) | Code read more than written; contract should be clear immediately |
```

## A Fitting Name

```
| Idea | Name | Pattern (Context → Conflicting Forces → Configuration) | Rationale |
|------|------|----------------------------------------------------------|-----------|
| Unique exported members | A Singular Name | When exporting utilities → namespace objects vs unique names → Avoid export const Utils = {} | Prevents conflicts, improves clarity |
| readonly types | An Unchanged Thing | When defining collections → mutable vs readonly → Use ReadonlyArray, ReadonlySet, etc. | Prevents accidental mutation |
| readonly prefix on interface props | A Fixed Property | When defining interfaces → mutable vs immutable properties → Prefix with readonly | Aligns with immutable data philosophy |
| function keyword for overloads | A Transparent Signature | When writing overloaded functions → arrow vs function → Use function keyword | TypeScript requires function for overload signatures |
```

---

### Appendix: Sources

- https://github.com/gordonbrander/pi-notational/blob/main/AGENTS.md
- https://www.evolu.dev/docs/conventions

*Category and pattern names are in Christopher Alexander style.*
