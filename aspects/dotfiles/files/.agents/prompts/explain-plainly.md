---
description: Do not let a term from another field carry the meaning — state the consequence, name the term in parentheses
---

$ARGUMENTS

If text was passed above, rewrite it under this rule; otherwise apply it to everything you write from here on.

A term borrowed from another field is not part of the domain's language. It brings assumptions nobody chose and asks the reader to translate from a field they do not share. So do not let it carry the meaning: state the consequence in ordinary words. You may still name the term in parentheses, as a pointer for readers who know it.

Terms the domain already uses are not affected; keep them.

Bad: "The retry writes the same row again, so the handler is idempotent."

Good: "A retry writes the same record again and leaves one copy, not two (idempotent)."
