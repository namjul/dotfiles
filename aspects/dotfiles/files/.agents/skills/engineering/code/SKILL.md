---
name: code
description: Use when turning a plan, request, or agreed change into working code. Triggers on "implement", "implement the plan", "build this", "code this", "execute the plan". Turns clear intent into working code, tests, and verification.
---

> Source: https://github.com/juanibiapina/dotfiles/tree/4417e56718e1429830503037755a5c3dc02d2d50/agents/skills/code/SKILL.md
> Imported from commit: `4417e56718e1429830503037755a5c3dc02d2d50`
> License: MIT, Copyright (c) 2026 Juan Ibiapina

# Code

Execute the plan from the conversation. If no plan is clear, ask what to build.

## Workflow

### 1. Understand

- Load relevant skills
- Review the plan from the conversation
- Ask if anything important is unclear
- Before concluding a pattern or file is missing, confirm the checkout is current (`git fetch`, fast-forward if behind upstream). A search miss on a stale checkout is a false negative.
- Do not skip this. Better to ask now than build the wrong thing.

### 2. Execute

Implement systematically:

- Follow existing patterns in the codebase. Read similar code first, match conventions.
- Make changes incrementally, one logical unit at a time
- Test as you go. Run relevant tests after each significant change, fix failures immediately.
- Don't overengineer. Do what the plan says, nothing more.
- Don't commit when coding is done.

### 3. Verify

After completing the work:

- Run the full test suite or relevant checks
- Review your changes for completeness against the plan
- Report what was done and flag anything that needs follow-up
