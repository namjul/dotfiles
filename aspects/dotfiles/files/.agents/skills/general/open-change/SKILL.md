---
name: open-change
description: Drive the current work to a GitHub pull request or GitLab merge request, from branch and commit through opening it with reviewers. Use when opening a change, opening a pull request or merge request, pushing changes for review, or when the user says "open change", "open PR", "create PR", "open MR", or "send for review".
---

> Source: https://github.com/juanibiapina/dotfiles/blob/619fe0276d15d9ed616e5ab1eeb35c4004ed87cb/agents/skills/open-pr/SKILL.md
> Imported from commit: `619fe0276d15d9ed616e5ab1eeb35c4004ed87cb`
> License: MIT, Copyright (c) 2026 Juan Ibiapina

# Open Change

Drive the current work to one open change. On GitHub that is a pull request. On GitLab that is a merge request.

Follow the workflow below, don't skip any steps.

Load other pull request and commit related skills if available, they may add different requirements.

# Workflow

## 1. Assess state

Determine where things stand and pick the path to a pushed branch with one open change.

Examples:

- On the default branch with changes: sync, branch, commit, push, open the change.
- On a branch with changes: commit, push, open or update the change.
- On a branch, clean: push if needed, open the change or check the existing one.
- A change for this branch is already open: sync, commit any new work, then update that change in [Push and open](#4-push-and-open). Do not open a second one.

Identify the forge from the remote host. `github.com`, and any host `gh` is logged into, is GitHub. A GitLab host `glab` is logged into, including self-hosted, is GitLab. If neither CLI can see the repo, stop. Do not push the default branch.

## 2. Sync with the default branch

Before opening the change, make sure the work sits on top of the latest remote default branch. Fetch and rebase before pushing when on a branch. When a rebase would require a force-push, stop and ask. Do not force-push unless the user explicitly asks.

## 3. Branch and commit

Commit the relevant changes with `git-commit`. A request to open the change is the explicit request to commit the work that belongs in it. Reference the ticket in the change body when one exists.

## 4. Push and open

Push the branch and open the change, using the repository template when one exists. Write the title and description with `documentation`. Use the forge reference under [Supported Targets](#supported-targets).

Request reviewers from CODEOWNERS for the paths in the diff, then recent reviewers in this repo, then collaborators, excluding the author. If none can be named, say so next to the change URL.

The result shows the change URL, or the reason the change was not opened (conflict, or unknown forge).

## Supported Targets

- `github`: See [references/github.md](references/github.md)
- `gitlab`: See [references/gitlab.md](references/gitlab.md)

## Add A New Target

Add `references/<target>.md` with these sections:

1. `## Authentication`
2. `## See where the branch stands`
3. `## Open or update`
4. `## Reviewers`
5. `## Template`

Add the target under `Supported Targets`. Keep the commands executable. Include one open example that requests a reviewer.
