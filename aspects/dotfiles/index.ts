import { assertNever, attributes, file, init, path, template, variable, variables } from "fig";

init(import.meta.dirname);

variables(({ identity }) => console.log("identity", identity) || ({
  files: [
    // root-level files
    ".xprofile",
    "Xresources",
    ".xmobarrc",
    ".togglrc",
    ".bashrc",
    ".tmux-cht-command",
    ".hgrc",
    ".tmux-cht-languages",
    ".fxrc",
    ".todo.cfg",
    ".default-npm-packages",
    ".bash_profile",
    ".stylua.toml",
    ".gitignore_global",
    ".tmux.conf",
    // individual .config files
    ".config/starship.toml",
    ".config/mimeapps.list",
    // symlinked directories
    ".xmonad",
    ".claude",
    ".config/pitchfork",
    ".config/darkman",
    ".config/shellfirm",
    ".config/environment.d",
    ".config/gtk-4.0",
    ".config/i3",
    ".config/nushell",
    ".config/timewarrior",
    ".config/octofriend",
    ".config/spyglass",
    ".config/xdg-desktop-portal",
    ".config/ripgrep",
    ".config/fish",
    ".config/zathura",
    ".config/opencode",
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
    ".config/pi",
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
  vcsUserEmail: identity === "namjul" ? "samuel.hobl@gmail.com" : "",
  vcsUserName: identity === "namjul" ? "Samuel Hobl" : "",
}));

if (import.meta.main) {
  const sub = Deno.args[0] as "dir" | "files" | "templates";

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
    default:
      assertNever(sub);
  }
}
