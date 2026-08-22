---
name: unfold
description: Test a task for a pocket of reducibility and, if one exists, unfold it into a generative sequence — an ordered list of structure-preserving transformations a fresh agent can execute end to end. Use when the user says "unfold", asks for a generative sequence, or wants a task compressed into a paste-ready build sequence. Do NOT force this on tasks whose core is judgment, taste, or values — declare those irreducible instead, and offer fundamental-sequence discovery mode, capturing any generative sequence found along the way.
---

# Unfold

Take a task, idea, or existing artifact and either (a) unfold it into a generative sequence, or (b) declare it computationally irreducible and switch to discovery mode. In a pocket of reducibility you *apply* a latent sequence; outside one, sequences are *discovered* — by-products of stepwise navigation, not inputs to it. A generative sequence is a correctly ordered list of small structure-preserving transformations: each step grows the previous whole into a slightly more differentiated whole, never assembling separately made parts. The deliverable is a short, scannable markdown artifact — the sequence itself — that a fresh agent can paste and follow.

## The Reducibility Gate

Before generating anything, test whether the task sits in a pocket of reducibility: recurring patterns, checkable success criteria, discoverable ordering, and convergence between competent builders. Irreducible when the core is taste, values, trade-offs under uncertainty, or novel context that does not transfer.

Output one line before the sequence: `Reducibility: pocket found — <one sentence why>` or `Reducibility: irreducible — <one sentence why>`. Mixed tasks: unfold the reducible shell; mark judgment points as `human: <what to taste>`. If the whole core is irreducible, do not emit an up-front sequence — name the judgment points and offer discovery mode.

## Discovery Mode (irreducible territory)

Attend to the whole, find the weakest or most latent center, propose one small structure-preserving transformation, let the human evaluate by felt sense, keep or revert, repeat. Never batch steps. When kept transformations turn out to be forced moves, offer to distill them into the standard sequence form (marking felt judgments as `human:` steps).

## Sequence Form

The artifact *is* the sequence — origami-short, not a plan wrapped in theory.

```markdown
# <Outcome name>

intent: <one sentence: what whole this grows>
context: [<vision | domain | ux-ui | stack | …>]

1. <small transformation — names a center or relation>
2. <builds only on what step 1 brought into being>
3. …
```

| Property | Rule |
|---|---|
| Atomic | One differentiation per step; ≤ ~1 line each |
| Clear | No hedging; name the center |
| Continuous | Adjacent steps read as one unfolding |
| Dependent | If a step can move freely, delete or demote it |
| Limited scope | Default ≤ ~12 steps; split later stages into named sibling sequences |
| Wholeness | After every step the thing is still a coherent whole |

**Paste contract:** only the fenced sequence above is paste-ready. Gate verdict, notes, and commentary stay outside the fence (or as a one-line `human:` step inside the list). Do not put essays, stack dumps, tool mechanics, or final-state specs in the paste artifact — leave room for the executor to generate detail.

**Genesis then outward:** seed → minimal working core → each capability as its own named sequence. Later sequences reference earlier ones by name, not by repetition. Steps name centers and relations, not procedures.

Worked fragment:

```markdown
# Genesis

## Notes That Grow

intent: A note-taking app where a personal knowledge base grows one note at a time.
context: [vision]

1. A knowledge base comes into being through small additions and links.
2. Every note strengthens the whole by connecting to notes that already exist.

## Stage 1: Minimal working core

intent: Smallest runnable loop where creating a note changes what is shown.
context: [ux-ui]

1. A `Note` exists as the unit everything else relates to.
2. `createNote` persists a note; the list re-derives from storage.
3. A note can be edited or deleted; the list stays consistent.
```

## Hard Constraints

- Do not report done until the gate verdict and (if reducible) the paste-ready fenced sequence are shown.
- Never emit an *up-front* sequence for a task gated as irreducible. A sequence distilled *after* discovery-mode work is the expected output of that mode.
- Never hide a judgment call inside a numbered step; surface it as `human: <what to taste>`.
- Limited scope wins over volume: if the sequence is hard to scan, it is not finished — split or cut.

## Sources

- Unfolding wholeness primer: [LLM Coding: Unfolding Wholeness & Living Structures](https://iamronen.com/blog/2026/08/14/llm-coding-unfolding-wholeness-living-structures/) (iamronen)
- Generative sequence primer: [LLM Coding: Generative Sequences](https://iamronen.com/blog/2026/08/16/llm-coding-generative-sequences/) (iamronen)
- Pockets of reducibility primer: [Grok conversation on Wolfram's pockets of reducibility and "Claudable" tasks](https://x.com/i/grok/share/6d7e3a7a648843e6ba16dadd4cff40f5) (via Ryan Singer)
- Biomarkers primer: [New Theory of the Body](https://thepopupschool.org/course/new-theory-of-the-body/) (The Pop-Up School)
