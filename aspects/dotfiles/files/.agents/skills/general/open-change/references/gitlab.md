# GitLab

Merge requests via `glab`.

## Authentication

- Check current auth state:
  - `glab auth status`
- Sign in to a GitLab instance:
  - `glab auth login`
- Target a specific repo when not inside a git clone:
  - `glab mr list --repo GROUP/PROJECT`

`glab` reads host and token configuration from `~/.config/glab-cli/config.yml`. `GITLAB_ACCESS_TOKEN` is enough for API calls. The HTTPS push path in the `gitlab` skill uses that token. Keep the token out of shell history and command output.

## See where the branch stands

```bash
glab repo view --output json --jq .default_branch
glab mr list --source-branch "$(git branch --show-current)" --output json
```

An empty list means no open merge request for this branch. Use the `default_branch` value as the target. Do not assume `main`.

Check that the source branch exists on the remote through the API. A 404 means push first. Never use `git ls-remote` (it may route through SSH). URL-encode branch names that contain `/`.

```bash
glab api "projects/:id/repository/branches/<urlencoded-branch>"
```

## Open or update

`--push` and `--fill` (which pushes unless `--push=false`) call `git push` against `origin` and need an SSH agent (`SSH_AUTH_SOCK`). Without one, push over HTTPS the way the `gitlab` skill describes, then create with `--push=false`.

`--description-file` and `--yes` keep the command non-interactive. `--description "-"` opens an editor and hangs.

```bash
cat > /tmp/open-change-body.md <<'MD'
Add a setting to turn off toasts. There is no way to stop these toasts today.

Closes #74.
MD

glab mr create \
  --title "Add a setting to turn off toasts" \
  --description-file /tmp/open-change-body.md \
  --target-branch DEFAULT_BRANCH \
  --push=false \
  --yes
```

When a reviewer was named, add `--reviewer REVIEWER`. When none can be named, omit it and say so next to the change URL.

When a merge request for the branch is already open, push if needed and add reviewers. `--reviewer +name` adds. A bare name replaces the reviewer list.

```bash
glab mr update MR_IID --reviewer +REVIEWER
```

Link an issue with `--related-issue IID`.

## Reviewers

`--reviewer` takes GitLab usernames, comma-separated or repeated.

1. CODEOWNERS for the paths in the diff. Look at `.gitlab/CODEOWNERS`, then `CODEOWNERS`.
2. Recent reviewers. Read `reviewers[].username` from merged merge requests:

```bash
glab mr list --merged --per-page 20 --output json
```

3. Project members, excluding the author:

```bash
glab api "projects/:id/members/all" | jq '.[].username'
```

## Template

`--template NAME` reads `.gitlab/merge_request_templates/NAME.md`. The `.md` suffix is optional. A value with a path separator is a file path. Use the template or `--description-file`, not both.

```bash
glab mr create \
  --title "Add a setting to turn off toasts" \
  --template default \
  --target-branch DEFAULT_BRANCH \
  --push=false \
  --yes
```

When a reviewer was named, add `--reviewer REVIEWER`. When none can be named, omit it and say so next to the change URL.
