# Fish functions

Autoloaded helpers under `~/.config/fish/functions`. Fish loads a file when you first call a function of the same name. After adding or editing a file, start a new shell or run `reload`.

This page is a 1:1 index of the functions you own here. Extra functions defined inside a file are listed in the same row. Vendored Pure prompt files (`_pure_*.fish`) are omitted.

## Overlaps

| You want | Use | Not |
|---|---|---|
| Insert a path onto the command line | Ctrl-F / `fzf-file-widget` in `fzf_key_bindings.fish` | `ff` (standalone picker; prints a path, does not complete the line) |
| Preview files then pick one | `ff` | Ctrl-F (no `bat` preview unless you set `$FZF_CTRL_T_OPTS`) |
| Open a pick in `$EDITOR`, skip images/PDFs | `fdo` (Ctrl-O) | `eff` (always `$EDITOR`) |
| Jump directory | Alt-C → `fzf_change_directory`; Alt-O → `yazicd` | `fzf-cd-widget` is defined by fzf but not bound |
| Git worktree add/remove | `gwa` / `gwd` | `ga` / `gd` are scmpuff aliases (`git add` / `git diff`) |
| `t` then Enter | function `t` (tmux attach or `Work`) | `abbr t todo` still expands `t<space>` |

`ff` and `fzf-file-widget` both run fzf over files. The widget walks from the token on the command line and inserts escaped paths. `ff` is a command: `fzf` plus `bat` preview, for piping (`sff`) or opening (`eff`).

## Index

| File | Function(s) | What it does |
|---|---|---|
| `_fzf_git_helpers.fish` | `is_in_git_repo`, `fzf-down` | Shared helpers for `gf`/`gb`/`gt`/`gc`/`gr` |
| `cd.fish` | `cd` | Alias to `zd` (zoxide when the arg is not a real path) |
| `claude.fish` | `claude` | Run `claude` inside `sandbox` |
| `codex.fish` | `codex` | Run `codex` inside `sandbox` |
| `compress.fish` | `compress` | `tar -czf <dir>.tar.gz <dir>` |
| `decompress.fish` | `decompress` | `tar -xzf` |
| `dip.fish` | `dip` | Kill `ssh -L port:localhost:port` forwards |
| `dsync.fish` | `dsync` | Confirm, then `dendron workspace sync` after `repos` |
| `eff.fish` | `eff` | `ff` then `$EDITOR` on the pick |
| `fdo.fish` | `fdo` | fzf pick; `$EDITOR` unless image/PDF → `open` |
| `ff.fish` | `ff` | `fzf` with `bat` preview |
| `fip.fish` | `fip` | `ssh -f -N -L` local forwards: `fip host port [port…]` |
| `fish_mode_prompt.fish` | `fish_mode_prompt` | Vi-mode indicator for the prompt |
| `fish_prompt.fish` | `fish_prompt` | Prompt entry (Pure) |
| `fish_title.fish` | `fish_title` | Terminal title |
| `fish_user_key_bindings.fish` | `fish_user_key_bindings` | Vi insert `jk`; binds fzf/`fdo`/`yazicd` |
| `fisher.fish` | `fisher` | Fisher plugin manager |
| `fzf_change_directory.fish` | `fzf_change_directory` | fzf over `most-wanted-dirs`, then `cd` |
| `fzf_key_bindings.fish` | `fzf_key_bindings`, `fzf-file-widget`, `fzf-history-widget`, `fzf-cd-widget` | Upstream fzf widgets; Ctrl-T family. `fzf-file-widget` is the line-complete counterpart to `ff` |
| `gb.fish` | `gb` | fzf git branches |
| `gc.fish` | `gc` | fzf git commits |
| `gf.fish` | `gf` | fzf git status files |
| `gr.fish` | `gr` | fzf git remotes |
| `gt.fish` | `gt` | fzf git tags |
| `gwa.fish` | `gwa` | `git worktree add -b` at `../<repo>--<slug>`; `mise trust`; `cd` |
| `gwd.fish` | `gwd` | Confirm, remove current linked worktree and delete its branch |
| `img2jpg.fish` | `img2jpg` | ImageMagick → `*-converted.jpg` (q85, strip) |
| `img2jpg-large.fish` | `img2jpg-large` | JPG, max 3160px on a side |
| `img2jpg-medium.fish` | `img2jpg-medium` | JPG, max 2160px |
| `img2jpg-small.fish` | `img2jpg-small` | JPG, max 1080px |
| `img2png.fish` | `img2png` | Lossless compressed PNG |
| `installNpmDefaults.fish` | `installNpmDefaults` | `npm install -g` from `~/.default-npm-packages` |
| `lfcd.fish` | `lfcd` | `lf`; `cd` to last directory on quit |
| `lip.fish` | `lip` | List `ssh … -L` forwards |
| `mkd.fish` | `mkd` | `mkdir -p` and `cd` |
| `n.fish` | `n` | `nvim .` if no args, else `nvim $argv` |
| `open.fish` | `open` | `xdg-open $argv` in the background |
| `pi.fish` | `pi` | Run `pi` inside `sandbox` |
| `reading.fish` | `reading` | Fetch a URL into a memex reading note via `pi` |
| `reload.fish` | `reload` | `source ~/.config/fish/config.fish` |
| `repos.fish` | `repos` | `git status` for every repo in the current folder |
| `s.fish` | `s` | Copy cwd or a path to the clipboard (`~`-prefixed) |
| `sandbox.fish` | `sandbox` | `bwrap`: tmpfs over `$SANDBOX_BLOCKED_FOLDERS`, `~/.ssh`, gpg sockets |
| `sff.fish` | `sff` | Newest-first files through `ff`, then `scp` to `$argv[1]` |
| `t.fish` | `t` | `tmux attach`, or `tmux new -s Work` |
| `tdl.fish` | `tdl` | Tmux layout: `$EDITOR .`, AI pane(s), terminal strip |
| `tdlm.fish` | `tdlm` | One `tdl` window per subdirectory |
| `tm.fish` | `tm` | fzf existing tmux sessions, attach or switch |
| `transcode-video-1080p.fish` | `transcode-video-1080p` | ffmpeg scale 1920×1080, H.264, copy audio |
| `transcode-video-4K.fish` | `transcode-video-4K` | ffmpeg HEVC re-encode + AAC; does not scale to 4K |
| `tsl.fish` | `tsl` | Tiled tmux panes all running the same command |
| `y.fish` | `y` | `yazi` and `cd` to the last directory |
| `yazicd.fish` | `yazicd` | Same as `y` (bound to Alt-O) |
| `zd.fish` | `zd` | Real path → `cd`; else zoxide `z` |

## Limits

- `_pure_*.fish` live in this directory but are not listed. `fisher.fish` / `fzf_key_bindings.fish` are vendored; treat them as upstream unless you own a local patch.
- `sandbox` requires `bwrap` and `$SANDBOX_BLOCKED_FOLDERS`.
- Image/video helpers need `magick` / `ffmpeg`.
- `gwa` creates a **new** branch; it fails if the branch or sibling directory already exists.
- `transcode-video-4K` is a slow HEVC remux/re-encode, not a 4K scaler.

When you add a function file, add a row here in the same change.
