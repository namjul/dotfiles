---
name: gitlab
description: Interact with GitLab issues, merge requests, and CI/CD pipelines using the `glab` CLI. Use when working with GitLab issues, merge requests, pipelines, job logs, or when the user mentions GitLab, merge requests, CI/CD, or a GitLab issue or merge request number.
---

# GitLab

Use GitLab CLI (`glab`) to create and update issues, merge requests, and interact with CI/CD pipelines.

## Authentication

- Check current auth state:
  - `glab auth status`
- Sign in to a GitLab instance:
  - `glab auth login`
- Target a specific repo when not inside a git clone:
  - `glab issue list --repo GROUP/PROJECT`

`glab` reads host and token configuration from `~/.config/glab-cli/config.yml`. No environment variables needed if the config file is set up.

## Issues

### Create issue

1. Build the issue body and append required context footer:

```bash
cat > /tmp/create-task-body.md <<'MD
<task details>

### Context
- session: [llm-session]
MD
```

2. Create the issue:

```bash
glab issue create \
  --title "Issue title" \
  --description "$(cat /tmp/create-task-body.md)" \
  --label "type:task,priority:p2" \
  --assignee USERNAME \
  --milestone "Sprint 12"
```

Or open in browser to fill in details:
```bash
glab issue create --web
```

### List and view

```bash
glab issue list                    # open issues
glab issue list --all              # all issues
glab issue list --label "bug"      # filter by label
glab issue view 42                 # view issue #42
glab issue view 42 --web          # open in browser
```

### Update

```bash
glab issue update 42 --label "priority:p1,type:bug"   # add labels
glab issue update 42 --unlabel "type:task"            # remove label
glab issue update 42 --assignee USERNAME              # reassign
glab issue update 42 --milestone "Sprint 13"          # change milestone
glab issue update 42 --due-date 2026-07-15            # set due date
```

### Comment

```bash
glab issue note 42 --message "Closing because merge request !123 was merged"
```

### Close / reopen

```bash
glab issue close 42
glab issue reopen 42
```

## Merge requests

### Create merge request

```bash
glab mr create \
  --push \
  --title "feat: add OAuth2 login" \
  --description "Implements PKCE for public clients." \
  --target-branch main \
  --label "feature" \
  --assignee USERNAME \
  --reviewer REVIEWER1,REVIEWER2 \
  --remove-source-branch \
  --yes
```

Auto-fill from commit history (`--fill` implies `--push`):
```bash
glab mr create --fill --yes
```

Create draft:
```bash
glab mr create --fill --draft --yes
```

Create merge request linked to an issue:
```bash
glab mr create --related-issue 42 --fill --yes
```

### List and view

```bash
glab mr list                       # open merge requests
glab mr list --merged              # merged merge requests
glab mr view 123                   # view merge request !123
glab mr diff 123                   # view diff
glab mr view 123 --web             # open in browser
```

### Update

```bash
glab mr update 123 --title "fix: resolve timeout"     # change title
glab mr update 123 --label "bug,auth"                 # set labels
glab mr update 123 --draft                            # mark as draft
glab mr update 123 --ready                           # mark as ready
```

### Comment / discuss

Short inline comment:
```bash
glab mr note create 123 --message "Addressed feedback in latest commit"
```

Long or Markdown bodies — pipe to stdin (avoids shell-quoting pitfalls):
```bash
glab mr note create 123 < /tmp/body.md
```

Inline multi-line body — quoted heredoc:
```bash
glab mr note create 123 << 'EOF'
Your **markdown** comment.
Code blocks and `inline code`, $variables are all literal.
EOF
```

Threaded reply:
```bash
glab mr note create 123 --reply <discussion-id> --message "I agree!"
```

Resolve / reopen a discussion:
```bash
glab mr note resolve 123 <discussion-id>
glab mr note reopen 123 <discussion-id>
```

### Merge

```bash
glab mr merge 123                              # merge
glab mr merge 123 --squash                     # squash and merge
glab mr merge 123 --auto-merge                 # merge when pipeline passes
```

### Approve / rebase / close

```bash
glab mr approve 123
glab mr rebase 123
glab mr close 123
```

## CI/CD pipelines

### View pipeline status

```bash
glab ci status                    # pipeline status for current branch
glab ci list                      # list pipelines
glab ci get                       # get pipeline details
```

Machine-readable output:
```bash
glab ci status --output json
glab ci get --pipeline-id <id> --output json
glab ci get --merge-request <iid> --with-job-details
```

### Jobs

```bash
glab ci retry <job-id>             # retry a job
 glab ci trigger <job-id>           # trigger a manual job
glab ci cancel job <job-id>        # cancel a job
glab ci cancel pipeline <id>       # cancel a pipeline
```

Fetch finished job log (non-blocking, safe for agent use):
```bash
glab api projects/:id/jobs/<job-id>/trace
```

Retry an entire pipeline (not a single job):
```bash
glab api projects/:id/pipelines/<pipeline-id>/retry -X POST
```

### Run pipeline

```bash
glab ci run                       # run pipeline on current branch
glab ci run --branch main         # run pipeline on a branch
```

### Lint CI config

```bash
glab ci lint                      # validate .gitlab-ci.yml
```

## Cross-repo operations

Use `--repo` to target a project other than the current directory:

```bash
glab issue list --repo group/project
glab mr view 123 --repo group/subgroup/project
glab ci status --repo group/project
```

## API calls

`glab api` auto-prepends `/api/v4/`. Use relative paths:
```bash
glab api user                              # NOT /api/v4/user
glab api projects/:id/issues | jq '.[0]'
```

Pass simple `key=value` pairs with `--field`. For rich Markdown bodies, write to a file and use `--field body=@file`:
```bash
glab api projects/:id/issues/:iid/notes --field body=@/tmp/comment.md
```

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Omitting `--message` on `note` commands | Always pass `--message`; without it `glab` opens `$EDITOR` and hangs |
| Using `--description "-"` | Opens `$EDITOR`; pass an explicit value or pipe from stdin instead |
| Using `--body` flag | `--body` is a `gh` flag; `glab` uses `--description` |
| `glab ci trace` in agent context | Blocks until job finishes; use `glab api projects/:id/jobs/<job-id>/trace` instead |
| `glab ci view` in agent context | Interactive terminal UI that blocks; use `glab ci status` or `glab ci get` |
| `glab ci retry` with pipeline ID | Takes a job ID only; to retry a pipeline use `glab api projects/:id/pipelines/<id>/retry -X POST` |
| Omitting `--push` on `glab mr create` | Remote branch may not exist; always include `--push` |
| Using `--state` on `mr list` | No such flag; use `--all`, `--merged`, or `--closed` |
| Issue threaded replies | `glab issue note` is root-level only; use `glab api .../discussions/<id>/notes` for threaded replies |

## Troubleshooting

| Error | Fix |
|-------|-----|
| `no GitLab host configured` | Run `glab auth login` or verify `~/.config/glab-cli/config.yml` |
| `HTTP 401` | Regenerate personal access token in GitLab → Settings → Access Tokens; ensure `api` scope |
| `HTTP 404` | Verify project path and issue or merge request internal ID; check project visibility |
| `failed to find repo remote` | Set `--repo GROUP/PROJECT` explicitly or run from inside a clone |
