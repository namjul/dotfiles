#!/usr/bin/env -S deno run --allow-all

import {
  assert,
  assertNever,
  file,
  init,
  path,
  stat,
  template,
  variable,
  variables,
  when,
} from "fig";

init(import.meta.dirname);

/** A secret whose plaintext has not been decrypted on this machine: the
 * ciphertext sits beside it, and `wage decrypt` materializes it. */
const skipNotDecrypted = async (source: string, label: string): Promise<boolean> => {
  if ((await stat(source)) !== null) return false;
  if ((await stat(`${source}.encrypted`)) === null) return false;
  console.log(`skip: ${label} (not decrypted; run wage decrypt)`);
  return true;
};

variables(({ identity }) => ({
  files: [
    // root-level files
    ".xprofile",
    "Xresources",
    ".xmobarrc",
    ".togglrc",
    ".bashrc",
    ".fxrc",
    ".todo.cfg",
    ".default-npm-packages",
    ".bash_profile",
    ".vimrc",
    ".stylua.toml",
    ".gitignore_global",
    ".npmrc",
    // individual .config files
    ".config/starship.toml",
    ".config/bash/rc",
    ".config/mimeapps.list",
    ".config/xdg-terminals.list",
    ".claude/settings.json",
    ".pi/agent/extensions",
    ".pi/agent/settings.json",
    ".pi/agent/models.json",
    ".pi/agent/mcp.json",
    ".pi/agent/themes/gruvbox-dark-soft.json",
    ".pi/agent/themes/gruvbox-light-soft.json",
    ".config/mise/config.toml",
    ".config/bat/config",
    // symlinked directories
    ".xmonad",
    ".config/pitchfork",
    ".config/darkman",
    ".config/shellfirm",
    ".config/environment.d",
    ".config/gtk-4.0",
    ".config/i3",
    ".config/niri",
    ".config/waybar",
    ".config/uwsm",
    ".config/kanshi",
    ".config/tmux",
    ".config/nushell",
    ".config/timewarrior",
    ".config/octofriend",
    ".config/spyglass",
    ".config/xdg-desktop-portal",
    ".config/ripgrep",
    ".config/fish",
    ".config/zathura",
    ".config/opencode/opencode.json",
    ".config/opencode/tui.json",
    ".config/yazi",
    ".config/wezterm",
    ".config/fnox",
    ".config/lf",
    ".config/flameshot",
    ".config/alacritty",
    ".config/foot",
    ".config/marksman",
    ".config/ncspot",
    ".config/dunst",
    ".config/mako",
    ".config/wofi",
    ".config/swayosd",
    ".config/swaylock",
    ".local/share/light-mode.d",
    ".local/share/dark-mode.d",
    ".local/share/applications",
    ".local/share/chromium/extensions",
    ".local/bin/mount-shares",
    ".local/bin/keepassxc-wf",
    ".local/bin/toggle-mic-mute",
    ".local/bin/theme-mode",
    ".local/bin/theme-apply",
    ".local/bin/wofi",
    ".local/bin/rofi",
    ".local/bin/btop",
    ".local/bin/file-select-portal",
    ".local/bin/share-via-localsend",
    ".local/bin/share-menu",
    ".local/bin/launch-webapp",
    ".local/bin/webapp-handler-gmail",
    ".config/ghostty",
    ".config/imv",
    ".config/mpv",
    ".config/vdirsyncer",
    ".config/espanso",
    ".config/notmuch",
    ".config/todotxt",
    ".config/spaced-inbox/config.txt",
    // hardlinks
    ".config/gammastep/config.ini",
    ".config/glab-cli/readme.md",
    ".config/wireguard/work.conf",
  ],
  templates: [
    ".config/git/config.tmpl",
    ".config/chromium-flags.conf.tmpl",
    ".hgrc.tmpl",
  ],
  skills: [
    ".agents/skills/seed/attractor-protocol",
    ".agents/skills/seed/unfold",
    ".agents/skills/seed/explore-writing-reviewer",
    ".agents/skills/seed/hegelian-dialectic-skill",
    ".agents/skills/seed/pivot-card",
    ".agents/skills/seed/ontoedit-analysis",
    ".agents/skills/seed/untangle-concept",
    ".agents/skills/general/agent-authoring",
    ".agents/skills/general/ai-writing-signs",
    ".agents/skills/general/browser-tools",
    ".agents/skills/general/caveman",
    ".agents/skills/general/conversation-capture",
    ".agents/skills/general/create-task",
    ".agents/skills/general/creative-guardian",
    ".agents/skills/general/etymology-research",
    ".agents/skills/general/flashcards",
    ".agents/skills/general/find-skills",
    ".agents/skills/general/manage-aspects",
    ".agents/skills/general/open-change",
    ".agents/skills/general/pause-and-expand-tutor",
    ".agents/skills/general/reflect",
    ".agents/skills/general/research",
    ".agents/skills/general/socratic-tutor",
    ".agents/skills/general/timewarrior",
    ".agents/skills/general/website-rebuild-workflow",
    ".agents/skills/general/yt-dlp",
    ".agents/skills/engineering/code",
    ".agents/skills/engineering/code-review",
    ".agents/skills/engineering/codebase-walkthrough",
    ".agents/skills/engineering/commit",
    ".agents/skills/engineering/commit-if-clear",
    ".agents/skills/engineering/deep-modules",
    ".agents/skills/engineering/documentation",
    ".agents/skills/engineering/explore-design-space",
    ".agents/skills/engineering/gitlab",
    ".agents/skills/engineering/investigate",
    ".agents/skills/engineering/minimal-step-pair-programming",
    ".agents/skills/engineering/neovim",
    ".agents/skills/engineering/openspec-generate-tutorial",
    ".agents/skills/engineering/plan",
    ".agents/skills/engineering/ponytail",
    ".agents/skills/engineering/review-architecture",
    ".agents/skills/engineering/socratic-code-mentor",
    ".agents/skills/engineering/sr-eng-review",
    ".agents/skills/engineering/video-compress",
    ".agents/skills/engineering/vocabulary",
    ".agents/skills/engineering/wizard",
    ".agents/skills/engineering/zx-markdown-scaffold",
  ],
  prompts: [
    ".agents/prompts/commit.md",
    ".agents/prompts/commit-plan.md",
    ".agents/prompts/commit-if-clear.md",
    ".agents/prompts/plan.md",
    ".agents/prompts/present.md",
    ".agents/prompts/wn.md",
    ".agents/prompts/code.md",
    ".agents/prompts/suppose.md",
    ".agents/prompts/ask.md",
    ".agents/prompts/unfold.md",
    ".agents/prompts/variants.md",
    ".agents/prompts/causal.md",
    ".agents/prompts/ontoedit.md",
    ".agents/prompts/tutor.md",
    ".agents/prompts/handoff.md",
    ".agents/prompts/mannered-prose.md",
    ".agents/prompts/explain-plainly.md",
    ".agents/prompts/review.md",
    ".agents/prompts/restate.md",
    ".agents/prompts/notes.md",
    ".agents/prompts/pi-update.md"
  ],
  rules: [
    ".agents/rules/caveman.md",
  ],
  agents: [".agents/AGENTS.md", ".agents/CLAUDE.md"],
  wireguard: [
    ".config/wireguard/work.conf",
  ],
  vcsUserEmail: identity === "namjul" ? "samuel.hobl@gmail.com" : "",
  vcsUserName: identity === "namjul" ? "Samuel Hobl" : "",
}));

if (import.meta.main) {
  const sub = Deno.args[0] as "dir" | "files" | "templates" | "agents";

  switch (sub) {
    case "dir": {
      await file({ path: "~/.config", state: "directory" });
      break;
    }
    case "files": {
      const files = variable.paths("files");

      const hardlinkFiles = new Set([
        ".config/gammastep/config.ini",
      ]);
      const skipOnArch = new Set([
        ".config/dunst",
        ".config/i3",
      ]);
      const skipOnDebian = new Set([
        ".config/mako",
        ".config/niri",
        ".config/waybar",
        ".config/uwsm",
        ".config/kanshi",
        ".config/wofi",
        ".config/swayosd",
        ".config/swaylock",
      ]);

      for (const src of files) {
        const rel = src.toString();
        if (when("arch") && skipOnArch.has(rel)) continue;
        if (when("debian") && skipOnDebian.has(rel)) continue;

        const source = path.aspect.join("files", src).toString();
        if (await skipNotDecrypted(source, rel)) continue;

        await file({
          force: true,
          path: path.home.join(src),
          src: source,
          state: hardlinkFiles.has(src.toString()) ? "hardlink" : "link",
        });
      }

      // `/etc/wireguard` is read by root, so the config is copied rather than
      // linked; the source is the checkout's plaintext, not the `$HOME` link,
      // so this step does not depend on the loop above having run.
      if (when("arch")) {
        for (const rel of variable.paths("wireguard")) {
          const source = path.aspect.join("files", rel).toString();
          if (await skipNotDecrypted(source, rel.toString())) continue;

          const r = await file({
            force: true,
            mode: "0600",
            path: path("/etc/wireguard", rel.basename.toString()),
            src: source,
            state: "copy",
            sudo: true,
          });
          if (!r.ok) {
            console.warn(
              `warn: skipped /etc/wireguard/${rel.basename} (${r.error.type})`,
            );
          }
        }
      }

      break;
    }
    case "templates": {
      const templates = variable.paths("templates");

      for (const src of templates) {
        await template({
          path: path.home.join(src.strip(".tmpl")),
          src: path.aspect.join("templates", src),
        });
      }
      break;
    }
    case "agents": {
      const piDestination = path.home.join(".pi", "agent");
      const destinations = [
        piDestination,
        path.home.join(".claude"),
        path.home.join(".config", "opencode"),
      ];

      const skills = variable.paths("skills");
      for (const src of skills) {
        for (const dest of destinations) {
          const r = await file({
            force: true,
            path: dest.join("skills", src.basename),
            src: path.aspect.join("files", src),
            state: "link",
          });
          assert.result(r);
        }
      }

      const prompts = variable.paths("prompts");
      for (const src of prompts) {
        const r = await file({
          force: true,
          path: piDestination.join("prompts", src.basename),
          src: path.aspect.join("files", src),
          state: "link",
        });
        assert.result(r);
      }

      const rules = variable.paths("rules");
      for (const src of rules) {
        for (const dest of destinations) {
          const r = await file({
            force: true,
            path: dest.join("rules", src.basename),
            src: path.aspect.join("files", src),
            state: "link",
          });
          assert.result(r);
        }
      }

      const agents = variable.paths("agents");
      for (const src of agents) {
        for (const dest of destinations) {
          const r = await file({
            force: true,
            path: dest.join(src.basename),
            src: path.aspect.join("files", src),
            state: "link",
          });
          assert.result(r);
        }
      }

      break;
    }
    default:
      assertNever(sub);
  }
}
