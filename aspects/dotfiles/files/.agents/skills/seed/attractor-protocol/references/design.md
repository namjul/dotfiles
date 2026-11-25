# Design: <name>

## Approach

Shape of the solution in plain terms.
Focus on architecture and approach, not line-by-line implementation.

## Rationale

Why this direction over alternatives.
Good design docs explain the "why" behind technical decisions.
If you considered other approaches and rejected them, say why.
Not looking for certainty. Just your current best thinking.

## Load-bearing assumptions

Technical bets that could be wrong.
If any of these prove false during implementation, update this document.

## Risks and trade-offs

What could go wrong even if our assumptions hold?
What are we trading off to go in this direction?
A risk is not the same as an assumption. It's what could hurt us even when we're right about the approach.

## Out of scope

Explicitly name approaches or scope you are leaving out.
This prevents scope creep and helps future readers understand the boundaries.

## Known unknowns

Technical questions still open.
No need to resolve these now. Just name them so they don't get forgotten.

## Co-variance

What else this motion will touch beyond the obvious structures.
Which parts of the codebase will this touch beyond the obvious?
Think about: what might break, what needs updating, what will behave differently.
Don't overthink. Just name what comes to mind.

## Design warnings

### Responsiveness

After this change, can users still tell what their actions did?
Is the system still talking back clearly?
If this intervention introduces delay, ambiguity, or silence between action and visible response, name it here.

### Continuity after correction

If a user makes a mistake and corrects it, do they land somewhere they can continue from, or just somewhere technically restored?
Does the approach preserve enough context that users don't lose their thread?

### Exploratory capacity

Does this approach narrow what users can discover or do by accident?
Interventions that increase precision often reduce exploration.
If this one does, name that cost explicitly.
