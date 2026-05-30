# anki-sync

Scans markdown files in the memex for embedded prompts and generates an Anki deck (`anki-decks/memex.apkg`) that can be manually imported.

The implementation is a single `.ts` file beginning with `#!/usr/bin/env -S deno run --allow-all`.

## Dependencies

- `npm:remark` + `npm:remark-parse` — parses markdown into an AST
- `jsr:@db/sqlite` — SQLite via temp file, read back as bytes
- `npm:jszip` — wraps bytes into `.apkg` ZIP
- `node:crypto` — synchronous SHA-256 / SHA-1

## File walking

Delegates to `git ls-files --cached --others --exclude-standard`, which applies all `.gitignore` rules including exceptions. Filters to `.md` files, then skips entries whose first path segment is in `{node_modules, scripts, assets, anki-decks}` and files whose name starts with `template.`. Reads the first 512 bytes of each candidate and skips the file if a null byte is found — the same binary-detection heuristic git uses.

## Parsing

Each file is parsed into an mdast AST using remark. The AST is walked to collect `paragraph` nodes. Code blocks (`code` nodes), list items (`listItem` nodes), and headings (`heading` nodes) are separate node types and are never visited.

Each paragraph produces two strings from its children: a full text (used for card content and GUIDs) and a masked text (used for pattern matching). `text` children contribute identically to both. `inlineCode` children contribute their backtick-wrapped value to the full text, but a same-length run of null bytes to the masked text — so `{...}` inside inline code never matches, while the inline code itself appears intact in the card.

### Q./A. pairs

A paragraph starting with `Q.` indicates a flashcard. Question and answer are each exactly one line — multilines are not allowed. The next line after `Q.` must start with `A.`; a blank line between them is optional.

At the AST level this produces two forms, handled as follows:

- **Single paragraph** (no blank line): full text is split by `\n`; the first line matching `^Q\. (.+)` is the question; blank lines are skipped; the next line must match `^A\. (.+)` to form a valid pair.
- **Two consecutive paragraphs** (blank line between): first paragraph's full text matches `^Q\. (.+)`; immediately following sibling paragraph's full text matches `^A\. (.+)`.

In both forms the `Q. ` and `A. ` prefixes are stripped from the captured text. Matched paragraphs are marked consumed and excluded from cloze matching.

GUID: `sha256(question + \x1f + answer).slice(0, 16)`

### Cloze paragraphs

Cloze deletions live inside prose — the deletion is meant to feel natural within its surrounding sentence, not extracted from it. Paragraphs not consumed by Q./A. matching, and not starting with `Q.`, `A.`, or `#`, are tested for `/(?<!\{)\{([^{}\n]+)\}(?!\})/g`. Each `{foo}` is converted to `{{c1::foo}}`, `{{c2::...}}`, etc.

GUID: `sha256(fullText).slice(0, 16)` where `fullText` is the string assembled from paragraph children — `text` children joined as-is, `inlineCode` children wrapped in backticks — before `{...}` → `{{cN::...}}` conversion. Hashing this string rather than raw file bytes ensures the GUID changes if and only if the card content changes.

## Tags

File path maps to a `::` -separated tag using Dendron-style dot notation: both `/` directory separators and `.` in filenames are treated as hierarchy levels. The `.md` extension is stripped, then each segment is passed through an aliases map before joining with `::`.

Aliases map (hardcoded in the script):

```ts
const ALIASES: Record<string, string> = {
  lang: "language",
  proj: "project",
  mv: "movement",
};
```

Examples: `philosophy.md` → `philosophy`, `memory/spaced-repetition.md` → `memory::spaced-repetition`, `language.english.vocabulary.md` → `language::english::vocabulary`, `person.david-bessis.attention-is-all-we-have.md` → `person::david-bessis::attention-is-all-we-have`.

## `.apkg` structure

An `.apkg` file is a ZIP containing a SQLite database (`collection.anki2`) and an empty media manifest (`media`). Anki reads the database on import.

The database has three meaningful tables:

**`col`** — singleton table (one row, 13 columns) storing global collection metadata. Two columns are relevant here:

`models` — a JSON map of model ID → model definition. Two models are defined:

- **Basic** (`id: 1342697561`, `type: 0`) — fields: `Front` (ord 0), `Back` (ord 1). One template: `qfmt: "{{Front}}"`, `afmt: "{{FrontSide}}<hr id=answer>{{Back}}"`.
- **Cloze** (`id: 1045689296`, `type: 1`) — fields: `Text` (ord 0), `Extra` (ord 1). One template: `qfmt: "{{cloze:Text}}"`, `afmt: "{{cloze:Text}}<br>{{Extra}}"`.

Each model entry carries: `id`, `name`, `type`, `mod` (Unix seconds), `usn` (-1), `sortf` (0), `did` (default deck ID), `flds` (field definitions with `name`, `ord`, `sticky`, `rtl`, `font`, `size`), `tmpls` (template definitions with `name`, `ord`, `qfmt`, `afmt`, `did`, `bqfmt`, `bafmt`), `css`, `latexPre`, `latexPost`, `req`, `tags`, `vers`. Model IDs are fixed constants — not derived — so they remain stable across runs and Anki can match them on reimport.

`decks` — a JSON map of deck ID → deck definition. One deck is defined: Default (id: 1).

**`notes`** — one row per prompt. Holds the content fields joined by `\x1f`, a GUID for stable identity across imports, and a tag string. The sort field (`sfld`) is the text of the field with `ord: 0` (`Front` for Basic, `Text` for Cloze). `csum` is a numeric checksum of `sfld` used by Anki for duplicate detection: `parseInt(createHash('sha1').update(sfld.toLowerCase()).digest('hex').slice(0, 8), 16)`.

**`cards`** — one row per reviewable card. A Basic note always produces one card row with `ord: 0`. A Cloze note produces N card rows, one per distinct `{{cN::}}` index — card row for deletion `{{cN::...}}` has `ord: N - 1`. Each card row blanks a different deletion when reviewed. All card rows start in the "new" state with no scheduling history.

## Test cases

### Q./A. — valid

No blank line between Q. and A.:
```
Q. What is the default HTTP port?
A. 80.
```

Blank line between Q. and A.:
```
Q. What is the default HTTP port?

A. 80.
```

Inline code in the answer:
```
Q. How do you destructure in JS?
A. Use `const { a, b } = obj`.
```

### Q./A. — invalid

Inside a fenced code block — `code` node never visited:
````
```
Q. Not a prompt.
A. Not an answer.
```
````

Text between Q. and A. — next non-blank line is not `A.`, pair skipped:
```
Q. What is entropy?
Thermodynamic concept.
A. Measure of disorder.
```

No following A. — orphaned Q. silently skipped:
```
Q. What is the airspeed velocity of an unladen swallow?
```

### Cloze — valid

Single deletion:
```
The mitochondria is the {powerhouse of the cell}.
```

Multiple deletions, three cards from one note:
```
Once activated, a service worker {performs startup computation}, transitions to {idle}, then handles {fetch or message events}.
```

Inline code alongside deletion — inline code appears in card, braces inside it are not matched:
```
Use `const { a, b } = obj` to {destructure an object}.
```

### Cloze — invalid

Inside a fenced code block — `code` node never visited:
````
```js
function foo({ x }) { return x; }
```
````

Inside inline code — masked during matching:
```
The syntax `{ key: value }` defines an object.
```

Spanning a newline — `[^{}\n]` excludes it:
```
The {concept that
spans a line} is prose.
```

Inside a list item — `listItem` node never visited:
```
- The {mitochondria} is the powerhouse.
```

In a heading — `heading` node never visited:
```
## The {concept} explained
```

## Duplicate prompts

If identical cloze text appears in more than one file, both produce the same GUID. Anki will silently overwrite the first note with the second on import. This is accepted behavior — identical text is identical content. Having the same prompt in multiple files results in the last file encountered (by filesystem walk order) overwriting earlier ones in the generated deck.

## Idempotency

GUID is the note's stable identity across imports. An unchanged note is skipped entirely by Anki on reimport — manually applied tags (`needs-review`, `mastered`) are preserved. Editing a prompt's text produces a new GUID and a new note; the old note remains in Anki untouched. **Known tradeoff:** this is a structural consequence of content-addressed identity — there is no mechanism to signal deletion or rename to Anki. Over time, edited prompts accumulate ghost cards that count toward review load and clutter search results. This is accepted as the cost of a stateless, append-only sync model.
