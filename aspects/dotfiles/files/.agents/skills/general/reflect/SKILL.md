---
name: reflect
description: Review chat session for mistakes, friction, and improvement opportunities; analyze and improve skills used
license: MIT
compatibility: pi
metadata:
  audience: all-users
  workflow: quality-improvement
---

## Success Criteria

Before presenting output, verify:

- ✅ Chat review covers mistakes, friction points, and unclear outputs
- ✅ Concrete, actionable improvements proposed (not vague suggestions)
- ✅ Skills invoked or read are analyzed for self-checks, conciseness, and quality
- ✅ Pattern detection identifies repeated tasks that could become skills
- ✅ Clear questions asked about what to remember for future chats

Iterate up to 5 times if criteria not met.

---

## What I Do

When the user types "reflect", I perform a comprehensive review of the current chat session:

### 1. Chat Session Review

- Analyze what we've accomplished
- Identify mistakes, errors, or incorrect assumptions
- Note friction points (repeated clarifications, confusion, corrections)
- Flag unclear or incomplete outputs
- Detect frustration signals from user

### 2. Improvement Proposals

- Generate concrete, actionable improvements (not vague suggestions)
- Prioritize high-impact changes
- Present as a short numbered list
- Ask which improvements to remember for future sessions

### 3. Skill Quality Analysis

For each skill invoked or read during this chat:

**a) Self-Check Validation:**

- A check belongs only where a silent skip would ship the wrong artifact.
- A CLI reference or a catalog already shows its work. Do not add a success-criteria block or an iterate cap to it.
- When a check is warranted, put it with the intent, require a visible artifact, and state what done forbids. Do not copy this skill's checklist into another skill.

**b) Token Efficiency:**

- Identify verbose sections that could be more concise
- Remove redundant instructions
- Suggest structural improvements
- Preserve clarity and functionality

**c) General Improvements:**

- Check for outdated patterns
- Identify missing edge cases
- Suggest better organization
- Propose enhanced instructions

### 4. Pattern Detection

- Monitor for tasks I'm asked to do repeatedly
- Suggest creating reusable skills for common patterns
- Ask for confirmation before creating new skills
- Provide skill name and description suggestions

### 5. Proactive Suggestions

Suggest typing "reflect" when:

- User corrects me multiple times on same topic
- User clarifies something twice or more
- User shows signs of frustration
- Workflow feels inefficient or repetitive

---

## When to Use Me

**Trigger explicitly when user types:**

- `reflect`
- `review session`
- `how are we doing?`

**Suggest proactively when:**

- User corrects the same mistake 2+ times
- User re-explains requirements
- Multiple back-and-forth exchanges on unclear point
- User expresses frustration (e.g., "no, that's not what I meant")
- Session feels inefficient

---

## Output Format

### Session Review

**Accomplishments:**

- [List what we completed]

**Mistakes/Issues:**

1. [Specific mistake with context]
2. [Friction point with example]

**Unclear Outputs:**

- [What was unclear and why]

### Proposed Improvements

1. **[Improvement area]:** [Concrete action]
2. **[Improvement area]:** [Concrete action]

**Which of these should I remember for future chats?** [Ask user]

### Skills Analysis

**Skills invoked or read:** [List skills]

For each skill:

**`skill-name`:**

- Check: [what a silent skip would ship, or "the work is the artifact"]
- Token efficiency: [Observations]
- Proposed improvements:
  1. [Specific improvement]
  2. [Specific improvement]

**Should I apply these improvements?** [Ask user]

### Pattern Detection

**Repeated tasks identified:**

- [Task pattern] (occurred X times)

**Suggested skill:** `suggested-name`

- Description: [What it would do]

**Should I create this skill?** [Ask user for confirmation]

---

## Implementation Notes

- Review entire conversation history, not just recent messages
- Count actual occurrences of patterns (don't guess)
- Be specific about mistakes (include line numbers, quotes, context)
- Distinguish between mistakes and intentional iteration
- Focus on systemic issues, not one-off clarifications
- When suggesting new skills, check if similar skill already exists
- Token efficiency improvements should preserve all functionality
- Self-check criteria should be specific and measurable

---

## Verification

Before presenting output:

1. Have I reviewed the full chat history?
2. Are all mistakes/friction points specific with examples?
3. Are improvements concrete and actionable?
4. Have I analyzed every skill invoked or read?
5. Are my questions clear and answerable?

If any answer is no, iterate and improve (up to 5 times).
