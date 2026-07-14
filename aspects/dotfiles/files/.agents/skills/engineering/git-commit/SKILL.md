---
name: git-commit
description: Create a commit (or draft a commit message) in a Git repository
---

Commit only when the user explicitly asks.

Review staged, unstaged, and untracked changes plus recent commit style. Draft a concise message that explains why. Stage the right files, commit, then verify with `git status`.

## Safety rules

- NEVER update git config
- NEVER run destructive commands unless explicitly requested
- NEVER skip hooks unless explicitly requested
- NEVER push unless explicitly asked
- NEVER force push to main or master
- NEVER use interactive git flags
- Do not create empty commits
- Do not commit likely secrets

## Amend rules

Use `--amend` only when all are true:
1. the user explicitly asked, or a successful commit auto-modified files via hooks
2. the HEAD commit was created by you in this conversation
3. the commit has not been pushed

If a hook fails, fix the issue and create a new commit.

## Best practices

- The body should explain the motivation for the change, and why the solution was chosen.
- Note alternatives which were considered but not implemented.
- Include references to previous commits or other artifacts (documentation, PRs) that are relevant.

## Auto-Clarity

Always include body for: breaking changes, security fixes, data migrations, anything reverting a prior commit. Never compress these into subject-only — future debuggers need the context.

## Boundaries

Only generates the commit message when the user mentions draft. This case does not run `git commit`, does not stage files, does not amend. Output the message as a code block ready to paste. 
