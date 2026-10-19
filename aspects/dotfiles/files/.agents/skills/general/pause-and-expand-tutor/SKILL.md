---
name: pause-and-expand-tutor
description: >
  From a YouTube link or an X post that is a video with a transcript, write a
  pause-and-expand tutor in the GSNV grammar beside a watching note. Use when
  the user gives a video URL and wants the tutor, says "pause and expand", or
  invokes /tutor.
---

Turn a video that has a transcript into a tutor that pauses where a familiar word is re-specified, a category shifts, or a question shows what the global-state natural view makes visible. The tutor is a companion to that talk. It is not a retelling in order, and it is not a toolbox app.

## Intent

- Get the transcript with the `yt-dlp` skill. If the link is not a video, or it has no transcript, stop and say so.
- An X post that points at a YouTube video uses that video for captions. Keep every URL the user gave.
- Clean the captions into readable speech, then build the tutor from that text. Do not stop after fetching captions.
- Teach with the `ontoedit-analysis` grammar: claimed versus earned, what is held fixed, timescale, threshold, contact. Do not score the talk. Do not upgrade a claim on a speaker's behalf. They asked for a document, so write the document.
- Hold one through-line and drop moments that do not serve it: the relation that makes a capacity available is also the question of what an explanation has earned.
- A lecture-length talk yields about twenty pauses. A short video yields fewer. Do not pad to hit a number.
- Draft the expansions in ordinary prose. Cut clusters of the signs in `ai-writing-signs`.

## Output

Write these three files next to each other. The slug is the lowercase hyphenated title.

- `watching.<slug>.md` — cleaned transcript, with the source URLs
- `watching.<slug>.tutor.html` — the tutor, one file, opened directly in a browser
- `watching.<slug>.tutor.md` — source URLs, the editorial rule, and how the page behaves

Before writing classes, open the daisyUI MCP and take the component class names from its docs. The page is an index of pauses, with the source links visible in the sidebar and at the top of each pause.

Each pause has four parts:

1. **The slice.** Exact excerpts from the cleaned transcript. Separate quotations need not be consecutive. Elapsed caption time marks the start; a later quotation carries its own time.
2. **What is happening here.** The immediate move.
3. **Tutor expansion.** The GSNV structure in that move. Not an additional statement by the speakers.
4. **A way to work with it.** A question or practice that makes the move usable.

Link each pause to the others it illuminates.

## Gotchas

- Correct a caption only when the right word is obvious, such as the speaker's own name. Leave a doubtful name as heard.
- The page the user opens must show the video link and the post link. A URL that exists only in the notes is missing.
- Do not put the tutor in `tool.llm` unless they ask for a reusable tool.
- Do not report done until a pause renders with all four parts and the source links are on the page.
