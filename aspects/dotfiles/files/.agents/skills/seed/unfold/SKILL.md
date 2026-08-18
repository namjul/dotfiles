---
name: unfold
description: Test a task for a pocket of reducibility and, if one exists, unfold it into a generative sequence — an ordered list of structure-preserving transformations a fresh agent can execute end to end. Use when the user says "unfold", asks for a generative sequence, or wants a task compressed into a paste-ready build sequence. Do NOT force this on tasks whose core is judgment, taste, or values — declare those irreducible instead, and offer fundamental-sequence discovery mode, capturing any generative sequence found along the way.
---

# Unfold

Take a task, idea, or existing artifact and either (a) unfold it into a generative sequence, or (b) declare it computationally irreducible and switch to discovery mode: hand navigation to human-in-the-loop fundamental-sequence work, from which a generative sequence may later be captured. In a pocket of reducibility you *apply* a latent sequence; outside one, sequences are *discovered* — by-products of stepwise navigation, not inputs to it. A generative sequence is a correctly ordered list of small structure-preserving transformations: each step grows the previous whole into a slightly more differentiated whole, never assembling separately made parts. The deliverable is a markdown artifact the user can paste into a fresh agent, which then builds the thing with no further context.

## The Reducibility Gate

Before generating anything, test whether the task sits in a pocket of reducibility. A pocket exists when a generative sequence already exists in latent form: the domain has recurring patterns, the success criteria are checkable without human felt experience, the ordering constraints are discoverable (X must exist before Y can be placed), and two competent builders would converge on substantially the same sequence. The task is irreducible when its core is taste, values, trade-offs under uncertainty, or novel context where what counted as good last time does not transfer — there the only path is step-by-step human deliberation, and generating a sequence would fake certainty the machine does not have.

Output the gate verdict visibly before the sequence, always: `Reducibility: pocket found — <one sentence why>` or `Reducibility: irreducible — <one sentence why>`. Mixed tasks are the common case: unfold the reducible shell and mark each judgment point inline as an explicit `human:` step stating what must be tasted, not what to decide. If the whole core is irreducible, do not emit an up-front sequence. Instead name the judgment points and offer the discovery path (below). Without stepwise navigation, the odds of finding living structure in an unbounded possibility space are poor — that is what "irreducible" means; it does not mean "no method exists."

## Discovery Mode (irreducible territory)

When the gate says irreducible, the applicable instrument is the fundamental sequence: attend to the whole, find the weakest or most latent center, propose one small structure-preserving transformation, let the human evaluate it by felt sense, keep or revert, repeat. The agent proposes candidate transformations; the human is the fitness function. Never batch steps — one transformation per evaluation.

As this loop runs, watch for steps that turned out to be forced moves — where the ordering constraint was real and any competent builder would have converged. Those are discovered fragments of a generative sequence. When the work reaches a stable whole, offer to distill the kept transformations into a sequence in the standard form (marking the genuinely felt judgments as `human:` steps). This converts the traversed region into a pocket of reducibility for next time.

## Sequence Form

Model the artifact on this shape:

```markdown
# <Title>

## <Sequence name>

intent: <one sentence: what whole this sequence grows>
context: [<vision | domain | ux-ui | technology-stack | ...>]

1. <transformation>
2. <transformation>
...
```

A worked fragment, from a note-taking application's genesis sequence:

```markdown
# Genesis

## Notes That Grow

intent: A note-taking application where a personal knowledge base grows one note at a time.
context: [vision]

1. A knowledge base comes into existence through a sequence of small additions and links.
2. Every note strengthens the whole by connecting to notes that already exist.

## Stage 1: Minimal working core

intent: Grow the runnable shell into the smallest loop where creating a note changes what is shown.
context: [ux-ui]

1. A `Note` exists as the unit everything else relates to.
2. `createNote` persists a note and the list re-derives from storage.
3. Every note can be edited or deleted, and the list stays consistent.
```

Rules that make a sequence generative rather than a plan:

- **Order is load-bearing.** Each step presupposes only what earlier steps created. You cannot place the countertop before the kitchen. If a step could move anywhere, it is a note, not a transformation.
- **Every step lands on a whole.** After each transformation the system is coherent and, once code exists, runnable — a bud growing, not parts awaiting assembly. Prefer many small differentiations over few large installations.
- **Start with a genesis sequence** stating intent, core domain concepts, and layer choices (stack, persistence, rendering), then unfold outward: seed → minimal working core → each capability as its own sequence. Later sequences reference earlier ones by name, not by repetition.
- **Steps name centers, not procedures.** "`Session`, `createSession`, expire/renew, audit trail" — the things brought into existence and the relationships between them. Omit tool mechanics the executing agent already knows.
- **Self-contained.** The artifact must carry everything a fresh agent needs: intent, constraints, stack decisions, ordering. If it depends on this conversation, it is not finished.

## Hard Constraints

- Do not report done until the gate verdict and (if reducible) the full paste-ready sequence are shown in the response or written to a file the user named.
- Never emit an *up-front* sequence for a task you gated as irreducible. A sequence distilled *after* discovery-mode work, recording transformations the human actually kept, is the expected output of that mode.
- Never hide a judgment call inside a numbered step; surface it as a `human:` step.
