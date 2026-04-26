---
name: conversation-capture
description: Capture complete conversation sessions as structured markdown files with preserved complexity and context, optimized for memex-style knowledge management
license: MIT
compatibility: pi
metadata:
  audience: power-users
  workflow: capture
---

## Success Criteria

Before executing, verify:

- ✅ Conversation context clearly identified
- ✅ Complete conversational flow preserved (questions, responses, edits)
- ✅ Complexity maintained without oversimplification
- ✅ Timestamp and metadata included
- ✅ Markdown structure facilitates future retrieval and linking
- ✅ Saved to user's memex location

Iterate capture if fidelity is compromised.

---

## What This Skill Does

When invoked, this skill captures the entire conversation session—including all user queries, assistant responses, code outputs, and reasoning—into a single markdown file suitable for memex-style knowledge management. The goal is **preservation of complexity** (not reduction) for later sense-making, pattern recognition, and idea development.

### Core Philosophy

Conversations contain emergent insights, dead-ends, clarifications, and conceptual development that get lost in summaries. This skill treats conversation as **primary source material** worth archiving in full, similar to:
- Lab notebooks in scientific research
- Zettelkasten in knowledge work
- Design logs in engineering

### Capture Approach

**1. Identify Sessions and Themes**

Clarify what constitutes this conversation:

- Starting point (first query/topic)
- Evolution path (how topic shifted)
- **Sidesteps and meta-discussions** (automatically detected via conversation pattern matching)
- Distinct thematic segments that may need separation
- Resolution or open threads

**AUTOMATIC THEMATIC BOUNDARY DETECTION:**

Do NOT rely on explicit markers like "sidestep:". Instead, detect boundaries through conversation structure:

**Pattern 1: Domain Vocabulary Shift**
- Sudden introduction of new technical vocabulary unrelated to prior topic
- Example: Conversation about parenting → discussion of "markdown", "skills", "workflows", "filenames"
- Signal: Content words from entirely different semantic field

**Pattern 2: Meta-Commentary**
- User begins discussing the conversation/tool/process itself
- Keywords: "capture", "skill", "workflow", "my notes", "save this", naming conventions
- Not the topic being discussed—the medium of discussion

**Pattern 3: Implementation vs. Inquiry**
- Shift from exploring a concept to building/creating something functional
- Example: Analyzing parenting → "I want a skill that does X" (building tool)
- Signal: Practical creation overtaking theoretical exploration

**Pattern 4: Pronoun/Referent Drift**
- "this" no longer refers to previous topic
- Anaphoric references break—new topic introduces new referents

**Pattern 5: Question Type Change**
- From substantive ("why does X happen?") to procedural ("how do I implement Y?")
- From domain-specific to tool-specific

**HANDLING DETECTED BOUNDARIES:**

When automatic detection identifies a thematic shift:

1. **Identify the dominant theme** (usually the first/main topic user engaged with)
2. **Assess separation need**: Is this a brief tangent or sustained new topic?
3. **Apply heuristics**:
   - Brief procedural note (< 3 exchanges) → keep in main file, label section
   - Sustained implementation work (> 3 exchanges on new topic) → separate file
   - User explicitly mentions capture/meta → strong signal for separation

4. **Default behavior**: Separate when confident; ask when ambiguous

**2. Structure Without Reduction**

Preserve the *form* of the conversation:

- Chronological flow (maintain sequence)
- Complete exchanges (don't truncate responses)
- Code blocks and outputs (if applicable)
- User corrections and clarifications
- Meta-commentary (automatically detected, e.g., discussions of capture process)

**3. Add Structural Metadata**

Enhance future retrievability:

- Frontmatter with dates, tags, themes
- Links to related concepts/files
- Summary section (added *after* preservation, not replacing)
- Lineage tracking (this emerged from that)

**4. Write to Memex**

Save to user's knowledge base:

- Location: ~/Dropbox/memex/
- Naming: llm-capture.{topic}.md
- No subdirectories created—flat organization with descriptive filenames
- Collision handling: if file exists, append -2, -3, etc. to topic

---

## Output Format

### File Structure

```markdown
---
title: "[Descriptive title of conversation]"
date: [YYYY-MM-DD]
time: [HH:MM]
tags:
  - [tag1]
  - [tag2]
  - [tag3]
source: opencode-session
lineage: [if this continues from another conversation]
---

## Summary

[Brief overview of what was explored—this is additive, not replacement for full text]

Key themes:
- [Theme 1]
- [Theme 2]
- [Theme 3]

## Conversation

### Initial Query

**User:** [Original question or prompt]

**Assistant:** [Complete response]

### [Section/Topic 1]

**User:** [Follow-up]

**Assistant:** [Response]

[Continue through all exchanges...]

### Sidesteps and Tangents

**User:** [Side inquiry]

**Assistant:** [Response]

### Evolution and Resolution

**User:** [Final clarifications or new directions]

**Assistant:** [Responses]

## Artifacts

- [Links to files created]
- [Code blocks worth preserving]
- [References mentioned]

## Open Threads

- [Questions not resolved]
- [Ideas to revisit]
- [Connections to investigate]
```

---

## When to Use This Skill

**Trigger when user:**

- Says "capture this conversation"
- Says "save this session"
- Says "I want to capture this"
- References "memex" or "notes" in context of preservation
- Asks to export or save the discussion
- Shifts to meta-discussion (automatically detected via pattern matching)

**Input formats:**

- `/capture` — capture entire current session
- "save this to my memex" — capture with default location
- "capture as [filename]" — capture with specific name
- Automatic detection of thematic boundaries (domain shift, meta-commentary)

---

## Examples

**Example 1: Philosophy discussion**

**User:** capture this conversation about parenting frameworks

**Response:** Creates file at ~/Dropbox/memex/llm-capture.parenting-helicoptering.md with complete exchange preserved.

**Example 2: Automatic thematic boundary detection**

**User:** [10 exchanges about parenting structures] ... i often have the workflow of wanting to capture the conversation without loosing complexity. i want to capture it as a markdown file in my notes

**Response:** Creates TWO files (automatically detected boundary):
- `llm-capture.parenting-structure.md` — contains the substantive conversation about parenting
- `llm-capture.skill-design.md` — contains the meta-discussion about creating the capture skill

**Detection signals:**
- Domain vocabulary shift ("parenting" → "markdown", "skills", "workflow")
- Meta-commentary (discussing capture process itself)
- Implementation vs. inquiry (building tool vs. exploring concept)
- Sustained new topic (> 3 exchanges on skill design)

Rationale: Automatic pattern matching identifies the shift. No explicit marker needed.

**Example 3: Multi-session continuation**

**User:** save this continuing our conversation about skill design

**Response:** Captures current session with `lineage: llm-capture.skill-design-patterns.md` in frontmatter.

---

## Capture Guidelines

### DO:

- Preserve complete responses (don't truncate for "brevity")
- Include user corrections ("actually...", "wait...")
- Maintain chronological order
- Capture code blocks and command outputs
- Add frontmatter with searchable tags
- Note emotional valence when relevant ("user frustrated", "breakthrough moment")
- Include failed approaches and reasoning
- Track conceptual evolution ("initially thought X, then shifted to Y")
- **Discern user intent**: What specific theme or conversation does user want captured?
- **Detect thematic boundaries automatically**: Use pattern matching (domain vocabulary, meta-commentary, implementation shifts)
- **Separate sustained new topics**: When conversation moves to different domain for > 3 exchanges, consider separate file
- **Ask when ambiguous**: "Do you want the parenting discussion, the skill-design portion, or both?"
- **Tag theme boundaries**: Label sections clearly when multiple themes kept in one file

### DON'T:

- Summarize away the complexity
- Remove "incorrect" turns in reasoning
- Reorder exchanges to make "cleaner" narrative
- Omit code or technical outputs
- Lose the context of how conclusions were reached
- Create executive summary that replaces full text
- **Mix unrelated themes without demarcation**: Don't combine parenting analysis with skill-design meta-work
- **Fail to detect automatic boundaries**: When domain vocabulary shifts or meta-commentary appears, recognize thematic boundary
- **Assume capture scope**: Clarify if user wants main topic, meta-discussion, or complete session

---

## Quality Standards

### Verification

Before saving file:

1. Does the file include the complete conversation from start to finish?
2. Are all user queries present?
3. Are all assistant responses complete?
4. Is the frontmatter populated with useful metadata?
5. Is the filename descriptive and dated?
6. Is the location correct (~/Dropbox/memex/...)?
7. Are code blocks and outputs preserved?

If any answer indicates missing information, review the session history and capture again.

---

## Critical Constraints

**NEVER:**

- Reduce conversation to bullet points
- Remove "incorrect" turns in reasoning
- Omit the process that led to conclusions
- Create summary that replaces full capture
- Lose chronological flow
- Ignore user's explicit capture requests

**ALWAYS:**

- Treat conversation as primary source worth preserving
- Add structure (frontmatter, headers) but don't filter content
- Include context of how topics emerged and shifted
- Note when user indicates something is important ("this is key")
- Preserve the actual words, not paraphrased versions
- Make file easily findable in user's knowledge base

---

## Implementation Notes

When invoked:

1. Review complete session history
2. Identify conversation boundaries (what counts as "this conversation")
3. Generate appropriate frontmatter
4. Structure with clear sections and headers
5. Write to ~/Dropbox/memex/llm-capture.[topic].md (or llm-capture.[topic]-2.md if collision)
6. Confirm save location and filename to user
7. Include summary as *additive*, not replacement

The captured file should serve as:
- Raw material for future thinking
- Source for extracted insights
- Record of how understanding developed
- Linkable node in user's knowledge graph
