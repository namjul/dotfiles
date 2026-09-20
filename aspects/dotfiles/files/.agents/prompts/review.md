---
description: Run a code review sub-agent
argument-hint: "[scope] [--provider X --model Y] [--thinking level] [--no-session]"
---

Spawn a sub-agent via bash to perform the code review. User scope and CLI options: $ARGUMENTS

Use `pi --print` with appropriate arguments. If the user specifies a model, pass `--provider` and `--model` accordingly; honor `--thinking` when given. Use `--no-session` for ephemeral one-shot reviews unless the user asks to keep the session.

Pass the sub-agent a prompt that loads the `sr-eng-review` skill and applies it to the user's scope (PR URL, branch, paths, staged/unstaged changes, etc.). When scope is omitted in a git repo, default to reviewing `git diff origin/master...HEAD`.

The sub-agent should focus on bugs and logic errors, security issues, and error-handling gaps, in addition to the skill's review dimensions.

Do not read or diff the code yourself. Let the sub-agent gather context and review.

Report the sub-agent's findings.
