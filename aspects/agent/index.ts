import { assert, file, init, path, variable, variables } from "fig";

init(import.meta.dirname);

variables(function () {
  return {
    skills: [
      "skills/general/conversation-capture",
      "skills/general/creative-guardian",
      "skills/general/etymology-research",
      "skills/engineering/minimal-step-pair-programming",
      "skills/general/reflect",
      "skills/personal/zx-markdown-scaffold",
      "skills/engineering/codebase-walkthrough",
      "skills/engineering/openspec-generate-tutorial",
      "skills/engineering/sr-eng-review",
      "skills/general/caveman",
      "skills/general/grill-me",
      "skills/general/chat-to-skill",
      "skills/general/skill-creator",
    ],
    rest: [
      "AGENTS.md",
    ]
  };
});

if (import.meta.main) {
  const destinations = [
    path.home.join(".claude"),
    path.home.join(".config", "pi", "agent"),
    path.home.join(".config", "opencode"),
  ];

  // setup skills
  {
    const files = variable.paths("skills");

    for (const src of files) {
      for (const dest of destinations) {
        const r = await file({
          force: true,
          path: dest.join("skills", src.basename),
          src: path.aspect.join("files", src),
          state: "link",
        });
        assert.result(r)
      }
    }
  }

  // setup rest
  {
    const rest = variable.paths("rest");
    for (const src of rest) {
      for (const dest of destinations) {
        const r = await file({
          force: true,
          path: dest.join(src),
          src: path.aspect.join("files", src),
          state: "link",
        });
        assert.result(r)
      }
    }
  }
}
