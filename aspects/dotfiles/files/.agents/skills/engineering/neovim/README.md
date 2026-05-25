# shannon

Neovim integration via RPC for annotated code review, walkthroughs, and navigation.

## Skills

- `/shannon:neovim`: Interact with Neovim via RPC to annotate code, navigate files, and do walkthroughs.

## Setup

Requires the [shannon nvim plugin](https://github.com/wincent/shannon) installed and loaded in the target Neovim. Given that, the skill obtains the Neovim server address either:

- automatically, by locating an nvim instance running in a sibling tmux pane (via `scripts/shannon-find-nvim.sh`), or
- explicitly, from a Shannon prompt footer (`(Shannon prompt via Neovim server /path/to/socket)`).

## Files

- `skills/neovim/SKILL.md`: Skill definition with RPC primitives and usage guidelines.
- `skills/neovim/scripts/shannon-find-nvim.sh`: Wrapper around the shannon nvim plugin's `bin/find-nvim-socket`. Requires shannon to be installed at the standard pack location (`~/.config/nvim/pack/bundle/opt/shannon/`).
