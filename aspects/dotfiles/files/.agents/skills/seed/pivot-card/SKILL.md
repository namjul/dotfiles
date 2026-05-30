---
name: pivot-card
description: Draws a random pivot card to break cognitive freeze when stuck on a problem. Each card is a concrete move that generates new information. Use when user is stuck, spinning, confused, or explicitly invokes /pivot-card.
---

# Pivot Card

Externalizes the choice of what to try next at the exact moment the brain defaults to ineffective loops (re-reading, wheel-spinning). Draw a card, apply it to the problem, execute — even badly. Wrong execution generates information. Hesitation generates nothing.

## Cards

| # | Card | Move |
|---|------|------|
| 1 | **Compute Something** | Pick any numbers and calculate. Don't wait for the right values — wrong numbers still reveal structure. |
| 2 | **Extreme Cases** | Push inputs to limits: zero, infinity, all-identical, empty, maximum. Watch what breaks or simplifies. |
| 3 | **Remove One Part** | Strip out one term, constraint, or component. Solve the simpler problem. Whatever collapses tells you what that part was actually doing. |
| 4 | **Reverse** | Run time, direction, or causality backwards. What asymmetry appears? That asymmetry is a real fact about the problem, not a framing accident. |
| 5 | **Rotate / Swap** | Change the frame, coordinate system, or swap labels/inputs/roles. Ask: what stays the same? what breaks? The invariants are the structure. |
| 6 | **Make Prediction** | Commit to a checkable claim before looking anything up — "if X then Y." Then verify. Forces the vague model to pay rent. Works best after 4–5 other cards when you've gathered enough data. |
| 7 | **Sit With Confusion** | Don't move yet. Locate exactly where the confusion is. Narrow it to one sentence: "I don't know why ___." Precision about what you don't know is itself progress. |

## Workflow

1. User is stuck or invokes `/pivot-card`
2. Roll a die — pick a number 1–7 at random (do not optimize, do not pick what seems most relevant)
3. State the card drawn
4. Explain concretely what that move means *for this specific problem*
5. Prompt the user to execute it now — explicitly grant permission to do it wrong

## Principles

- **Random pick breaks the freeze.** The point is not to choose optimally — it's to stop the loop. Any card beats staring.
- **Execute wrong on purpose.** Don't evaluate "how exactly should I do this?" — that overhead kills the attempt. Use obviously wrong numbers, absurd cases, imperfect swaps. Wrong execution reveals why it's wrong, which exposes constraints and hidden structure.
- **Motion precedes clarity.** The understanding comes from doing the move, not from deciding which move to do.
- Over time the moves become internal. Weight toward cards that feel unfamiliar — those are still expanding how you think.

## Source

Developed from a comment by Paul on David Bessis's Substack: https://davidbessis.substack.com/p/attention-is-all-we-have/comment/209394137
