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
    ".hgrc",
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
    ".config/pi/agent/extensions/notify.ts",
    ".config/pi/agent/settings.json",
    ".config/pi/agent/models.json",
    ".config/pi/agent/themes/gruvbox-dark-soft.json",
    ".config/pi/agent/themes/gruvbox-light-soft.json",
    // symlinked directories
    ".xmonad",
    ".agents",
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
    ".config/mise",
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
    ".config/wireguard/work.conf.encrypted",
  ],
  templates: [
    ".config/git/config.tmpl",
    ".config/wireguard/tunnel.conf.tmpl",
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
    ".agents/skills/engineering/minimal-step-pair-programming",
    ".agents/skills/engineering/commit",
    ".agents/skills/engineering/codebase-walkthrough",
    ".agents/skills/engineering/openspec-generate-tutorial",
    ".agents/skills/engineering/sr-eng-review",
  ],
  agents: ".agents/AGENTS.md",
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
        if (encrypted) {
          await file({
            force: true,
            path: path.home.join(src.strip(".encrypted")),
            src: path.aspect.join("files", src),
            state: "encrypted",
          });
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

      const skilles = variable.paths("skills");
      for (const src of skilles) {
        for (const dest of destinations) {
          const r = await file({
            force: true,
            path: dest.join("skills", src.basename),
            src: path.home.join(src),
            state: "link",
          });
          assert.result(r);
        }
      }

      const agents = variable.path("agents");
      for (const dest of destinations) {
        const r = await file({
          force: true,
          path: dest.join(agents.basename),
          src: path.home.join(agents),
          state: "link",
        });
        assert.result(r);
      }

      break;
    }
    default:
      assertNever(sub);
  }
}
