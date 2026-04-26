import { assert, file, init, path, variable, variables } from "fig";

init(import.meta.dirname);

variables(function () {
  return {
    files: [
      "skills/agency-composition-config",
      "skills/agency-getting-started",
      "skills/agency-primitive-extraction",
      "skills/conversation-capture",
      "skills/creative-guardian",
      "skills/etymology-research",
      "skills/minimal-step-pair-programming",
      "skills/reflect",
      "skills/zx-markdown-scaffold",
      "AGENTS.md",
    ],
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
    const files = variable.paths("files");

    for (const src of files) {
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
