---
name: timewarrior
description: Help the user track, annotate, inspect, summarize, and export time with Timewarrior while preserving their tag conventions. Use for natural-language time-tracking requests, date-range reports, and JSON exports.
---

# Timewarrior

Translate the user's intent into safe, inspectable Timewarrior commands. Preserve the user's tag vocabulary without inventing context names: `@context` denotes broad context, while `+facet` denotes a project, phase, activity, or ticket.

## Workflows

- Start and stop tracking with `timew start` and `timew stop`.
- Annotate the active interval with `timew annotate`.
- Add a completed interval with `timew track`.
- Summarize tracked time with `timew summary`.
- Export matching intervals as JSON with `timew export`.

Use explicit ranges when the user names a period. For example, “this week until yesterday” means:

```bash
timew summary from monday to yesterday
timew export from monday to yesterday
```

Preserve supplied tags exactly:

```bash
timew start @context +project +activity
timew summary from monday to yesterday @context +project
```

Treat `@123` as an interval ID when it appears in a command that addresses a specific interval. Do not delete or modify intervals without showing the target and getting confirmation. When a date expression is ambiguous, ask one focused question before running a command.
