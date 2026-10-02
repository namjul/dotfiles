---
description: Restate goals and problem for alignment before acting
argument-hint: "[focus]"
---

Restate in your own words what the user is trying to achieve and the problem they are solving. Use the full conversation, open files, and any attached context. When `$ARGUMENTS` is non-empty, weight that focus but still reflect the thread as a whole.

## Constraints

- **Read-only.** Do not edit files, run mutating commands, implement, plan implementation, or commit unless the user explicitly asked for that in the same turn.
- Separate **stated** (explicit in the thread) from **inferred** (interpretation). Mark inference clearly.
- Do not praise the question or the user's clarity. Do not pad with filler.
- End with a short invitation to correct or refine the restatement. Do not assume alignment and move on to execution in this turn.

## Output

Keep the restatement concise and proportional to available context.

1. **Goals** — outcomes the user wants; note priority if multiple goals compete
2. **Problem** — what is wrong, missing, blocked, or unclear that motivates the work
3. **Success** — observable criteria for “done” when the thread supports them; omit or mark inferred if thin
4. **Constraints and non-goals** — boundaries, exclusions, or fixed choices already on the table
5. **Open questions** — ambiguities that would materially change approach if answered differently

If the thread is too thin to restate responsibly, say what is missing and ask one focused question instead of inventing goals.

$ARGUMENTS
