---
name: commit
description: Reviews the working tree, writes a commit message that explains why, and creates the commit. Use when the user asks to commit, says "commit", asks to commit and push, or asks to merge.
---

> Source: https://github.com/juanibiapina/dotfiles/tree/be634998a40adb2a4e399af4fcdb1bcaac2f9304/agents/skills/git-commit/SKILL.md
> Imported from commit: `be634998a40adb2a4e399af4fcdb1bcaac2f9304`
> License: MIT, Copyright (c) 2026 Juan Ibiapina

# Git Commit

Review the uncommitted changes and recent commit style. Load the `documentation` skill and write the message by its rules. Commit only the changes that belong to the request. Other sessions edit this checkout too. Read each file's diff and leave out lines this session did not write, including lines inside a hunk you changed.

Amend an unpublished local commit when a small fix clearly belongs with that commit's intent. Ask before rewriting pushed, reviewed, or shared history.

If a hook fails, fix the issue and create a new commit.

## Guardrails

- NEVER update git config
- NEVER run destructive commands unless explicitly requested
- NEVER skip hooks unless explicitly requested
- NEVER push unless explicitly asked
- NEVER force push to main or master
- NEVER use interactive git flags
- Do not create empty commits
- Do not commit likely secrets

