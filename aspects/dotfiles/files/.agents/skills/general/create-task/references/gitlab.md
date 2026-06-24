# GitLab

## Authentication

- Check current auth state:
  - `glab auth status`
- Sign in to a GitLab instance:
  - `glab auth login`
- Target a specific repo when not inside a git clone:
  - `glab issue list --repo GROUP/PROJECT`

`glab` reads host and token configuration from `~/.config/glab-cli/config.yml`. No environment variables needed if the config file is set up.

## Add task

1. Build the issue body and append required context footer:

```bash
cat > /tmp/create-task-body.md <<'MD'
<task details>

### Context
- session: [llm-session]
MD
```

2. Create issue:

```bash
glab issue create \
  --title "Issue title" \
  --description "$(cat /tmp/create-task-body.md)"
```

3. Optional create-time metadata:

```bash
glab issue create \
  --title "Issue title" \
  --description "$(cat /tmp/create-task-body.md)" \
  --label "type:task,priority:p2" \
  --assignee USERNAME \
  --milestone "Sprint 12"
```

## Add tags

- Add labels:
  - `glab issue update ISSUE_IID --label "type:task,priority:p1"`
- Remove labels:
  - `glab issue update ISSUE_IID --unlabel "priority:p1"`

## Add due dates

GitLab issues have a native due-date field.

- Set due date on creation:
  - `glab issue create --title "Task" --due-date 2026-07-15`
- Set due date on existing issue:
  - `glab issue update ISSUE_IID --due-date 2026-07-15`

## Custom fields

GitLab does not have a native custom-field system for issues. Use these patterns instead:

1. Labels for categorical values (priority, type, status):
   - `glab issue update ISSUE_IID --label "priority::high,status::in-progress"`

2. Milestones for time-boxing and sprint tracking:
   - `glab issue update ISSUE_IID --milestone "Sprint 12"`

3. Epics for grouping related issues across milestones:
   - `glab issue create --title "Task" --epic EPIC_ID`

4. Weight for effort estimation:
   - `glab issue update ISSUE_IID --weight 3`
