---
name: untangle-concept
description: Decompose a tangled concept into its overlapping senses and the dimensions that distinguish them. Use when someone is confused because a single word means several different-but-related things (not homonyms like "bat"), when a debate is stuck because participants use the same term differently, when a user asks "what do people actually mean by X?", asks to "untangle" or "disambiguate" a concept, says "people use X to mean different things", or wants to clarify which sense of a concept matters in their context. Also use when user invokes "untangle-concepts", "conceptual variance decomposition", or "explicative regression" by name.
---

# Untangle Concepts

## Overview

People tangle semantics constantly. "Freedom," "justice," "power," "innovation," "trust" — each word covers several overlapping-but-distinct senses that speakers conflate. Debates stall, arguments talk past each other, and thinking stays muddy because the concept hasn't been decomposed.

This skill performs **Conceptual Variance Decomposition**: it breaks a concept into its overlapping senses, identifies the dimensions that distinguish them, and shows each sense as approximate weights on those dimensions. The purpose is practical — help people see *which* sense they mean and *why* it matters.

## When to Use

- User asks "what do people actually mean by X?"
- A debate is stuck because participants use the same term differently
- User wants to clarify which sense of a concept applies in their situation
- User says "untangle," "disambiguate," "unpack," or "decompose" a concept
- User invokes the skill by name

## Critical Constraint: Overlapping Senses Only

This skill handles **polysemy** (one word, related but distinct senses), NOT **homonymy** (one word, unrelated meanings).

**Yes:** "Power" → effectiveness, authority, coercion (overlapping, share family resemblance)
**No:** "Bat" → baseball bat, flying mammal (discrete, no shared semantic structure)

If the concept's senses don't overlap, say so and stop. The framework only works when senses share enough structure that dimensions can cut across all of them.

## Process

### Step 1: Expand the Concept into Senses

Identify 3–6 distinct-but-overlapping ways people use the term. For each sense:

- Give it a short name: "[Concept] as [Sense]"
- One sentence capturing its core meaning
- A characteristic sentence someone would say when using this sense

**Quality check:** Each sense should be recognizable to a thoughtful speaker as "yes, people do mean that sometimes." Avoid theoretical or obscure senses unless the user's context demands them. Avoid discrete/unrelated meanings.

State the **naive centroid** — the blurred folk understanding that doesn't distinguish the senses. This is what most people would say if asked "what does X mean?" and it's the baseline the decomposition improves on.

### Step 2: Brainstorm Dimensions

Generate 4–7 candidate dimensions that cut across the senses. A good dimension:

- Produces **different scores** for different senses (it discriminates)
- Is **legible** — a non-specialist can understand what it measures
- Is **independent** of other dimensions (low VIF — not the same insight in different vocabulary)

For each candidate dimension:
- Name it in 2–4 words
- State what it measures as a question (e.g., "Does this form of power depend on holding a formal position?")
- Score it 0–1 across all senses, with brief rationale

**Discard** dimensions that:
- Score the same across all senses (no discriminatory power)
- Correlate highly with another dimension (redundant — fuse them or drop one)
- Require specialist knowledge to evaluate

**Keep** 3–5 final dimensions.

### Step 3: Build the Score Table

Present a code-fenced, space-padded table with senses as rows and dimensions as columns. Keep dimension labels short in the table header; put scale descriptions in a key below.

````
```
                      D1: [Name]  D2: [Name]  D3: [Name]
C1: [Sense]                0.X         0.X         0.X
C2: [Sense]                0.X         0.X         0.X
C3: [Sense]                0.X         0.X         0.X
```

D1: [Name] (0=[low end], 1=[high end])
D2: [Name] (0=[low end], 1=[high end])
D3: [Name] (0=[low end], 1=[high end])
````

Code-fenced tables survive copy-paste into plain-text systems (email, Slack, notepad) with alignment intact. Markdown tables do not.

Scores are approximate — this is not quantitative research. They should be defensible, not precise. Use increments of 0.1 or 0.05; finer resolution is false precision.

### Step 4: Read the Table for the User

For each sense, narrate what the dimension profile tells you. The goal is a sentence like:

> "[Sense] scores high on [D1] and low on [D2], which means it's the version of [Concept] where [plain-language implication]."

Then identify where senses are **close** on the dimensions (this is where they get tangled) and where they're **far apart** (this is where disambiguation has the most leverage).

### Step 4b: Write the Tangle Entries

For each tangled pair, use this three-part structure:

1. **Name the pair and why they tangle.** Identify which dimensions they score similarly on — this shared profile is *why* speakers conflate them. Include a concrete example sentence where the tangle actually occurs in natural speech.
2. **Name the untangling dimension.** The one dimension where they diverge most.
3. **Provide a diagnostic question.** A plain-language question the speaker can ask themselves to determine which sense they mean. The question should target the untangling dimension directly. Format: *"Ask: [question]? If [answer A], you're talking about [Sense X]. If [answer B], [Sense Y]."*

The diagnostic question is the most important output of the skill. It's the tool the user walks away with. It should be concrete, short, and usable in real conversation.

**Use simple, recognizable examples throughout.** The tangle entries should feel like moments the reader has actually experienced — a sentence they've heard, a debate they've been in, a confusion they've felt. Abstract descriptions of where senses overlap are less useful than a single sentence that makes the reader say "oh, *that's* the tangle."

### Step 5: Apply to the User's Context

If the user brought a specific situation, debate, or question:

- Identify which sense(s) are active in their context
- Name which dimensions matter most for their purposes
- Show what shifts if they switch senses

If no specific context was given, offer a general diagnostic:

> "When people argue about [Concept], the tangle is usually between [Sense A] and [Sense B], because they score similarly on [D1] but diverge on [D2]. Clarifying [D2] usually untangles the disagreement."

## Output Format

```
## [Concept]: Untangled

### The Blur
[Naive centroid — what people mean when they haven't thought about it]

### The Senses
C1: [Concept] as [Sense] — [one sentence]
C2: [Concept] as [Sense] — [one sentence]
C3: [Concept] as [Sense] — [one sentence]
...

### The Dimensions
D1: [Name] — [question it asks]
D2: [Name] — [question it asks]
D3: [Name] — [question it asks]
...

### Score Table
[code-fenced space-padded table]

[key with dimension scales]

### Reading the Table
[narrative interpretation of each sense's profile]

### Where They Tangle
For each tangled pair:
- [Sense A] and [Sense B] tangle because [shared dimension scores]. [Concrete example sentence where the tangle occurs in natural speech.]
- Untangling dimension: [Dx].
- Ask: "[diagnostic question]?" If [answer A], [Sense A]. If [answer B], [Sense B].

### For Your Situation (if applicable)
[application to user's specific context]
```

## Worked Example: Power

### The Blur
"Power means being able to make things happen or control people."

### The Senses
- C1: Power as Effectiveness — the capacity to produce intended effects. "She has the power to change that organization's culture."
- C2: Power as Formal Authority — positionally granted control over decisions. "The Secretary has the power to approve the application."
- C3: Power as Coercion — compelling behavior through threat. "The regime maintained power through surveillance."

### The Dimensions
- D1: Institutional Dependence — does it require holding a formal position?
- D2: Voluntary Compliance — does it depend on the target choosing to go along?
- D3: Generativity — does it increase or decrease total capacity in the system?

### Score Table

```
                      D1: Institutional  D2: Voluntary  D3: Generative
C1: Effectiveness              0.2            0.7            0.9
C2: Authority                  0.95           0.8            0.5
C3: Coercion                   0.5            0.1            0.15

D1: Institutional (0=no formal position needed, 1=requires formal position)
D2: Voluntary (0=compliance is forced, 1=compliance is willing)
D3: Generative (0=contracts capacity, 1=expands capacity)
```

### Reading the Table
- **Effectiveness** scores low on institutional dependence and high on generativity — it's the version of power that *creates* rather than *controls*, and doesn't need a title to operate.
- **Authority** is almost entirely institutional and depends on voluntary deference — it collapses the moment people stop recognizing the position.
- **Coercion** is defined by its near-zero voluntary compliance — it operates *despite* the target's will — and contracts total capacity in the system.

### Where They Tangle
- **Authority and Effectiveness** tangle because both score moderately high on Voluntary Compliance — people go along in both cases. When someone says "she's the most powerful person in the building," they could mean she holds the highest title or that she's the one who actually moves things. 
  - Untangling dimension: Institutional Dependence.
  - Ask: "Could this person still do this without the title?" If yes, you're talking about effectiveness. If no, authority.

- **Effectiveness and Coercion** tangle less often, but when they do, both can operate outside institutions. "He gets results" can mask whether people follow willingly or out of fear.
  - Untangling dimension: Generativity.
  - Ask: "Does this expand what's possible, or just compel compliance?" If it expands, effectiveness. If it compels, coercion.

## Failure Modes

**Too few senses.** If you can only find two senses, the concept may not be tangled — it may just have a simple ambiguity. Two senses can work but check whether there's genuine overlap or just a binary distinction.

**Senses that are actually the same.** If two proposed senses score identically across all dimensions, collapse them. They're the same sense with different examples.

**Dimensions that don't discriminate.** A dimension that scores 0.5 across all senses is not a dimension — it's a shared property. Drop it.

**Too abstract.** Dimensions should be answerable with reference to concrete cases, not philosophical debate. "Is it deontological?" is too abstract. "Does it require following explicit rules?" is concrete.

**Mixing polysemy and homonymy.** If the senses don't share family resemblance, the framework breaks — the dimensions won't cut across them meaningfully. Flag this and stop.

## Integration with Other Skills

**Dimensionalize:** Use *after* untangling, to select which dimensions matter for a specific decision. Untangle identifies the semantic axes; Dimensionalize evaluates them for action.

**Rhyme:** Use to discover non-obvious senses by asking "what other concept has this same tangle?" If "trust" tangles like "power" does, import the dimensional structure.

**Excavate:** Use to go deeper on a single sense — once untangled, you can excavate the assumptions beneath one particular usage.

**Antithesize:** Use to stress-test a proposed dimension by generating the strongest case that it doesn't actually discriminate.

# Source

- https://github.com/anielsen108/claude-skills-public/blob/main/untangle-concept/skill.md
