
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


# Improvements

```json
{
   "assessment": "request changes",
   "files_reviewed": [
     {
       "location": "AGENTS.md",
       "issues": [
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "high",
           "description": "Missing async/await patterns - no guidance on Promise handling,
 error handling in async functions, or concurrent operations (Promise.all, Promise.race)",
           "suggested_fix": "Add pattern for 'An Async Flow' or similar - When handling
 async operations → Promise chains vs async/await → Use async/await with proper error
 handling"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "high",
           "description": "Missing error handling patterns - no guidance on typed errors,
 Result/Either patterns, or error boundary strategies",
           "suggested_fix": "Add pattern for 'A Caught Problem' - When handling errors →
 generic errors vs typed errors → Use typed error unions for better error handling"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "high",
           "description": "Missing generics guidance - no patterns for generic type
 parameters, constraints, or default types",
           "suggested_fix": "Add pattern for 'A Flexible Shape' - When creating reusable
 components → concrete types vs generics → Use generics with constraints for flexibility"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "medium",
           "description": "Missing enum vs const vs literal types guidance - important
 TypeScript decision not covered",
           "suggested_fix": "Add pattern for 'A Chosen Value' - When defining constants →
 enums vs const assertions vs literal types → Use const assertions for type safety without
 runtime overhead"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "medium",
           "description": "Missing type guards and narrowing patterns - no guidance on
 discriminating unions or type narrowing",
           "suggested_fix": "Add pattern for 'A Narrow Path' - When narrowing types → type
 assertions vs type guards → Use type guards for safe narrowing"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "medium",
           "description": "Missing exhaustive switch checking - no guidance on ensuring all
 cases are handled",
           "suggested_fix": "Add pattern for 'A Complete Match' - When handling unions →
 partial vs exhaustive → Use exhaustiveness checking with never type"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "medium",
           "description": "Missing module organization patterns - no guidance on barrel
 files, re-exports, or import ordering",
           "suggested_fix": "Add pattern for 'A Shared Entry' - When organizing modules →
 scattered imports vs barrel files → Use index.ts files for clean public APIs"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "medium",
           "description": "Missing early return / guard clause patterns",
           "suggested_fix": "Add pattern for 'An Early Exit' - When validating inputs →
 nested conditions vs guard clauses → Use early returns to reduce nesting"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "low",
           "description": "Missing branded types / nominal typing patterns",
           "suggested_fix": "Add pattern for 'A Marked Type' - When needing nominal typing →
 structural vs branded types → Use branding for semantic type distinction"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "low",
           "description": "Missing utility types guidance (Partial, Required, Pick, Omit,
 etc.)",
           "suggested_fix": "Add pattern for 'A Transformed Type' - When modifying types →
 manual vs utility types → Use built-in utility types for common transformations"
         },
         {
           "location": "AGENTS.md:missing section",
           "category": "completeness",
           "severity": "low",
           "description": "Missing config object pattern - no guidance on many arguments vs
 options object",
           "suggested_fix": "Add pattern for 'A Gathered Option' - When passing multiple
 parameters → many arguments vs config object → Use config objects for 3+ optional
 parameters"
         }
       ]
     }
   ],
   "task_categories_found": [
     "Functional programming style",
     "Type definitions (interfaces vs types)",
     "Import/export patterns",
     "Array operations",
     "Class patterns",
     "Module organization",
     "Naming conventions"
   ],
   "task_categories_missing": [
     "Async/await patterns",
     "Error handling strategies",
     "Generic types",
     "Enum/const/literal decisions",
     "Type guards and narrowing",
     "Exhaustive checking",
     "Barrel files and re-exports",
     "Guard clauses",
     "Branded types",
     "Utility types",
     "Config objects"
   ],
   "summary": "The AGENTS.md covers foundational patterns well (functional style, type system basics, imports/exports, naming). However, it is missing several important TypeScript categories: async programming, error handling, generics, and practical patterns for real-world TypeScript development. The guide would benefit from adding patterns for these areas to be comprehensive."
 }
```
