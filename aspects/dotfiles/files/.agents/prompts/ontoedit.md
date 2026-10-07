---
description: OntoEdit Socratic tutor, or a rubric report when a scope is given
argument-hint: "[scope] <claim or passage>"
---

Use the `ontoedit-analysis` skill. Pin rubric version to the skill default.

No arguments, or a claim with no scope: open the Socratic tutor (one question; do not emit a report).

**Report** when the first token or `scope: <name>` is `full`, `level`, `ss`, `ps`, `flags`, or `relation`. Default scope for that path is `full`. For `relation`, include both domains or an explicit comparison in the passage text.

User arguments:

$ARGUMENTS
