# GitHub

Pull requests via `gh`.

## Authentication

- Check current auth state:
  - `gh auth status`
- Sign in:
  - `gh auth login`
- Opening a pull request uses the default `repo` scope.

## See where the branch stands

```bash
gh repo view --repo OWNER/REPO --json nameWithOwner,defaultBranchRef --jq '{repo: .nameWithOwner, base: .defaultBranchRef.name}'
gh pr view --repo OWNER/REPO --json number,url,state,reviewRequests
```

`gh pr view` with no number uses the pull request for the current branch. A non-zero exit means there is no open pull request for this branch.

Use `defaultBranchRef.name` as the base. Do not assume `main`.

## Open or update

Write the body, then push, then open. `git push -u origin HEAD` is enough when `origin` is the GitHub remote.

```bash
cat > /tmp/open-change-body.md <<'MD'
Add a setting to turn off toasts. There is no way to stop these toasts today.

Closes #74.
MD

git push -u origin HEAD

gh pr create \
  --repo OWNER/REPO \
  --base DEFAULT_BRANCH \
  --title "Add a setting to turn off toasts" \
  --body-file /tmp/open-change-body.md
```

When a reviewer was named, add `--reviewer REVIEWER`. When none can be named, omit it and say so next to the change URL.

When the pull request already exists, push and leave it open. Edit the title or body when the user asked, or when the open body is still a placeholder.

```bash
gh pr edit NUMBER --repo OWNER/REPO --add-reviewer REVIEWER
```

## Reviewers

`--reviewer` and `--add-reviewer` take a user login or a team slug `org/team`, without `@`.

1. CODEOWNERS for the paths in the diff. Look at `.github/CODEOWNERS`, then `CODEOWNERS`, then `docs/CODEOWNERS`.
2. Recent reviewers:

```bash
gh pr list --repo OWNER/REPO --state merged --limit 20 --json reviews \
  --jq '[.[].reviews[].author.login] | unique | .[]'
```

3. Collaborators, excluding the author:

```bash
gh api repos/OWNER/REPO/collaborators --jq '.[].login'
```

## Template

Pass a file name from `.github/PULL_REQUEST_TEMPLATE/` or a path. Use the template as the body when it exists; fill its sections. Do not pass `--template` and `--body-file` together.

```bash
gh pr create \
  --repo OWNER/REPO \
  --base DEFAULT_BRANCH \
  --title "Add a setting to turn off toasts" \
  --template pull_request_template.md
```

When a reviewer was named, add `--reviewer REVIEWER`. When none can be named, omit it and say so next to the change URL.

Common paths: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`.
