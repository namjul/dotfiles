---
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "<next session focus>"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) rather than the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts such as specs, plans, ADRs, issues, commits, or diffs. Reference them by path or URL instead.

Redact sensitive information, including API keys, passwords, and personally identifiable information.

If arguments were passed, treat them as the description of what the next session will focus on and tailor the document accordingly.

Arguments: $ARGUMENTS
