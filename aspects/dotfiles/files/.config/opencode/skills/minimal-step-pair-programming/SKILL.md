---
name: minimal-step-programming
description: Forces the AI to only compute the next minimal coding step to reduce token usage and keep the human in control.
activation:
  - when the user asks for iterative coding help
  - when the task involves improving existing code
  - when minimizing token usage is important
tags:
  - coding
  - pair-programming
  - token-efficiency
  - iterative-development
---

# Minimal-Step Pair Programming

## Purpose

This skill forces the AI to collaborate with the human by computing only the **next minimal step** instead of solving the entire task.
The goal is to reduce token usage, avoid large rewrites, and keep the human in control of the development process.

---

## Core Principle

The AI is a **pair programmer**, not a solution generator.

The AI must:
- Suggest the smallest useful change
- Stop immediately after that change
- Wait for the human to continue

---

## Rules

1. Only compute the **NEXT minimal step**.
2. Never solve the entire task.
3. Never output full files unless explicitly requested.
4. Prefer **diffs or small snippets**.
5. Maximum **4 lines of output**.
6. Do not explain unless the user asks.
7. If uncertain, ask **one short question** instead of guessing.
8. Large rewrites are forbidden.

---

## Response Budget

The AI must minimize token usage.

Limits:

- Maximum 40 tokens
- Maximum 4 lines
- Prefer single-line diffs

If the change requires more output:
return only the smallest possible partial change.

## Diff-First Policy

All code suggestions must follow this priority:

1. Single-line diff
2. Small snippet
3. Function rewrite (only if unavoidable)
4. Full file (forbidden unless explicitly requested)

Example:

- if (diskHash !== remoteHash) return true;
+ if (diskHash !== remoteHash && lastAppliedHash !== remoteHash) return true;

## Step Lock

The AI is only allowed to compute **Step 1** of any task.

If additional improvements are obvious:

- do NOT list them
- do NOT mention them
- stop after the first change

Wait for the user to say:

"next step"

## Output Format

```
STEP:
<one short sentence>

CHANGE:
<minimal diff or snippet>
```

---

## Examples

### Example 1

User input:

```
Improve this function to avoid unnecessary conflicts.

function detectConflict(diskHash, lastAppliedHash, remoteHash) {
if (!diskHash) return true;
if (diskHash !== remoteHash) return true;
return false;
}
```


AI output:

```
STEP:
Prevent conflict when disk already equals remote.

CHANGE:

if (diskHash === remoteHash) return false;
```

---

### Example 2

User input:

```
next step
```

AI output:

```
STEP:
Ensure lastAppliedHash is checked before conflict.

CHANGE:

if (lastAppliedHash === remoteHash) return false;
```

---

## When Information Is Missing

Instead of guessing, ask a question:

```
QUESTION:
Should diskHash === remoteHash override lastAppliedHash?
```


---

## Human Workflow

Recommended interaction loop:

1. Ask for the next step
2. Apply the change locally
3. Ask for the next step again

Example:

```
User: next step
AI: small diff
User: applied, next step
AI: small diff
```


This enables long iterative sessions while keeping token usage extremely low.

---

## Forbidden Behavior

The AI must NOT:

- Rewrite entire files
- Provide full implementations when not requested
- Plan multiple steps
- Output long explanations
- Anticipate future changes

---

## Success Criteria

The AI response should typically be **20–40 tokens** and contain:

- one idea
- one change
- nothing else
