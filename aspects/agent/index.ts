import { assert, file, init, path, variable, variables } from "fig";

init(import.meta.dirname);

variables(function () {
  return {
    files: [
      "skills/general/conversation-capture",
      "skills/general/creative-guardian",
      "skills/general/etymology-research",
      "skills/engineering/minimal-step-pair-programming",
      "skills/general/reflect",
      "skills/personal/zx-markdown-scaffold",
      "skills/engineering/codebase-walkthrough",
      "skills/engineering/openspec-generate-tutorial",
      "skills/engineering/sr-eng-review",
      "AGENTS.md",
    ],
  };
});

if (import.meta.main) {
  const destinations = [
    path.home.join(".claude", "skills"),
    path.home.join(".config", "pi", "agent", "skills"),
    path.home.join(".config", "opencode", "skills"),
  ];

  // setup skills
  {
    const files = variable.paths("files");

    for (const src of files) {
      for (const dest of destinations) {
        const r = await file({
          force: true,
          path: dest.join(src.basename),
          src: path.aspect.join("files", src),
          state: "link",
        });
        assert.result(r)
      }
    }
  }
}
