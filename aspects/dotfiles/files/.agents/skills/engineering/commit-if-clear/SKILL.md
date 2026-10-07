---
name: commit-if-clear
description: Plan commits, then classify each open question for whether a human must answer it before committing. Commit with the git-commit skill only when none are urgent. Use when the user asks to plan and commit if the open questions are not urgent, or invokes commit-if-clear.
---

# Commit if clear

Follow the `commit-plan` prompt to completion, then decide whether those open questions block a commit. Invoking this skill is the request to commit, and that request applies only after the gate below is clear. `$ARGUMENTS` are extra focus for the plan.

During planning, do not stage, commit, push, or otherwise change git state. The plan's **Open questions** section is the gate input. No questions, or an explicit none, is a clear gate: skip classification and commit.

## Gate

Classify every open question in one `codemode` script. Take the first model from `models.getAvailableOfType("classifier")`. If that list is empty, or any call does not stop cleanly, stop and say so. Do not commit, and do not decide urgency yourself.

A question is urgent when a different answer would change which files are committed, how the changes are split, or whether a change is committed. It is not urgent when the plan can be carried out without that answer.

Embed the question strings in this script and run it:

```js
const available = await models.getAvailableOfType("classifier");
if (available.length === 0) return { error: "no classifier" };
const model = available[0];
const questions = []; // each open-question string
const results = await Promise.all(
  questions.map((question) =>
    models.classify(model, {
      state: { question },
      questions: {
        urgent: {
          type: "bool",
          instructions: "Must a human answer this before any commit?",
          criteria: {
            true: "A different answer would change the files, the split, or whether something is committed, and the plan does not already settle it.",
            false: "The planned commits can be made without this answer.",
          },
        },
      },
    })
  ),
);
return {
  model: { provider: model.provider, id: model.id },
  results: results.map((result, i) =>
    result.stopReason === "stop"
      ? { question: questions[i], probability: result.answers.urgent.probability }
      : { question: questions[i], error: result.errorMessage },
  ),
};
```

Urgent means `probability >= 0.5`, or the call returned an error. Before asking or committing, show each question with its probability and urgent or not. That list is the gate record.

## Stop or commit

Any urgent question: ask the user only those questions, with `cursor_ask_question` when it is available. Stop. Do not load `git-commit`.

None urgent: load the `git-commit` skill and make the planned commits in order. When the plan has more than one commit, isolate each slice with the stash workflow from the commit-plan prompt. The git-commit safety rules still apply. Do not push. Write messages in the repo's existing commit style, using each planned commit's purpose. The "output only the message" commit note does not apply once this gate is clear.

Do not stop after the plan or the gate record. Done means either the urgent questions have been asked, or `git status` has been shown after the commits.
