#!/usr/bin/env -S deno run --allow-all

import {
  assert,
  assertNever,
  file,
  init,
  path,
  template,
  variable,
  variables,
} from "fig";

init(import.meta.dirname);

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
    ".stylua.toml",
    ".gitignore_global",
    // individual .config files
    ".config/starship.toml",
    ".config/mimeapps.list",
    ".claude/settings.json",
    ".config/pi/agent/extensions",
    ".config/pi/agent/settings.json",
    ".config/pi/agent/models.json",
    ".config/pi/agent/themes/gruvbox-dark-soft.json",
    ".config/pi/agent/themes/gruvbox-light-soft.json",
    ".config/mise/config.toml",
    // symlinked directories
    ".xmonad",
    ".config/pitchfork",
    ".config/darkman",
    ".config/shellfirm",
    ".config/environment.d",
    ".config/gtk-4.0",
    ".config/i3",
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
    ".config/i3status-rust",
    ".config/fnox",
    ".config/lf",
    ".config/flameshot",
    ".config/alacritty",
    ".config/marksman",
    ".config/ncspot",
    ".config/dunst",
    ".local/share/light-mode.d",
    ".local/share/dark-mode.d",
    ".local/share/applications",
    ".local/bin/mount-shares.encrypted",
    ".config/ghostty",
    ".config/imv",
    ".config/vdirsyncer",
    ".config/espanso",
    ".config/notmuch",
    ".config/todotxt",
    // hardlinks
    ".config/bat/config",
    ".config/redshift/redshift.conf",
    ".config/rofi/config.rasi",
    ".config/btop/btop.conf",
    // encrypted
    // ".config/glab-cli/config.yml.encrypted",
    // ".config/wireguard/work.conf.encrypted",
  ],
  templates: [
    ".config/git/config.tmpl",
    ".hgrc.tmpl",
    // ".config/wireguard/tunnel.conf.tmpl",
  ],
  skills: [
    ".agents/skills/personal/zx-markdown-scaffold",
    ".agents/skills/general/conversation-capture",
    ".agents/skills/general/creative-guardian",
    ".agents/skills/general/etymology-research",
    ".agents/skills/general/reflect",
    ".agents/skills/general/caveman",
    ".agents/skills/general/grill-me",
    ".agents/skills/general/chat-to-skill",
    ".agents/skills/general/skill-creator",
    ".agents/skills/general/new-aspect",
    ".agents/skills/general/skill-discovery",
    ".agents/skills/general/youtube-transcript",
    ".agents/skills/engineering/minimal-step-pair-programming",
    ".agents/skills/engineering/commit",
    ".agents/skills/engineering/codebase-walkthrough",
    ".agents/skills/engineering/openspec-generate-tutorial",
    ".agents/skills/engineering/sr-eng-review",
  ],
  rules: [
    ".agents/rules/caveman.md",
  ],
  agents: [".agents/AGENTS.md", ".agents/CLAUDE.md"],
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
        ".config/bat/config",
        ".config/redshift/redshift.conf",
        ".config/rofi/config.rasi",
        ".config/btop/btop.conf",
      ]);
      for (const src of files) {
        const encrypted = src.toString().endsWith(".encrypted");
        const isLocalBin = src.toString().includes(".local/bin/");

        if (encrypted) {
          const r = await file({
            force: true,
            mode: isLocalBin ? "0755" : "0600",
            path: path.home.join(src.strip(".encrypted")),
            src: path.aspect.join("files", src),
            state: "encrypted",
          });
          assert.result(r);
          continue;
        }

        if (hardlinkFiles.has(src.toString())) {
          await file({
            force: true,
            path: path.home.join(src),
            src: path.aspect.join("files", src),
            state: "hardlink",
          });
          continue;
        }

        await file({
          force: true,
          ...(isLocalBin ? { mode: "0755" } : {}),
          path: path.home.join(src),
          src: path.aspect.join("files", src),
          state: "link",
        });
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
      const destinations = [
        path.home.join(".claude"),
        path.home.join(".config", "pi", "agent"),
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
