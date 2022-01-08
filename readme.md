# dotfiles [⛰ ](screenshot.png)

## Parts

- list of [software i use](scripts/brew)
- globally installed [npm packages](dots/default-npm-packages)
- [neovim](dots/.config/nvim/init.lua)
- [tmux config](dots/tmux.conf)
- [alacritty](dots/alacritty.yml)
- [gitconfig](dots/gitconfig)
- [fish configuration](dots/.config/fish/config.fish)
- [aliases](dots/.config/fish/alias.fish), [functions](dots/.config/fish/functions.fish)
- [starship](dots/starship)
- [espanso](dots/.config/espanso/default.yml)
- [zathura](dots/.config/zathura/zathurarc)
- [ripgrep](dots/.ripgreprc)

## Dependencies

### Homebrew

Homebrew needs to be setup for scripts to work.
This can be done by adding the following to `~/.profile`:

```sh
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
```

## Installation

Clone dotfiles to home directory

```
git clone https://github.com/namjul/dotfiles
```

and run the install script

```
./install
```

It will:

1. install brew packages
2. setup symlinks
3. setup vim configuration files and downloads `vim-plug` if it does not exist
4. install `asdf` plugins

## Postinstallation

### `asdf`

To make `asdf` work add the following to `~/.profile`:

```sh
source $(brew --prefix asdf)/asdf.sh
```

## Cli Workflows

### Navigation

| Mapping  | Functionality             |
| -------- | ------------------------- |
| `Ctrl-o` | fuzzy file and `open`     |
| `Ctrl-f` | fuzzy file                |
| `Alt-c`  | fuzzy folders and `cs`    |
| `Alt-o`  | open `lf` file explorer   |
| `z`      | `cd` using magic          |
| `db`     | `cd` into `~/Dropbox`     |
| `dd`     | `cd` into `~/.dotfiles`   |
| `dc`     | `cd` into `~/code`        |
| `-`      | cd into previous location |
| `..`     | `cd ..`                   |
| `...`    | `cd ../..`                |
| `....`   | `cd ../../..`             |

## Vim Keyboard shortcuts

**Legend**
`<leader>` == `space`
`C` == ctrl key

### Navigation

| Mapping       | Functionality             | Replaced Mapping |
| ------------- | ------------------------- | ---------------- |
| <leader>a     | add spot                  |                  |
| <leader>s     | list spots                |                  |
| <leader>j     | navigation to spot 1      |                  |
| <leader>k     | navigation to spot 2      |                  |
| <leader>l     | navigation to spot 3      |                  |
| <leader>ö     | navigation to spot 4      |                  |
| <leader>f     | fuzzy find files          |                  |
| <leader>b     | fuzzy find buffer         |                  |
| <leader>c     | fuzzy find commands       |                  |
| <leader>d     | dendron lookup            |                  |
| <leader><C-L> | dendron search            |                  |
| <leader><C-I> | open daily note           |                  |
| <leader>y     | dotfiles fuzzy find files |
| <leader>gb    | browser git branches      |                  |
| [d            | previous diagnostic       |                  |
| ]d            | next diagnostic           |                  |
| gf            | go to file                |                  |
| gd            | go to definition (lsp)    |                  |
| gr            | show references (lsp)     |                  |
| -             | open file explorer        |                  |
| <leader>m     | maximaize window          |                  |
| <C-W>h        | move to left pane         |                  |
| <C-W>l        | move to right pane        |                  |
| <C-W>k        | move to top pane          |                  |
| <C-W>j        | move to bottom pane       |                  |

### Search/Editing

| Mapping    | Functionality      | Replaced Mapping |
| ---------- | ------------------ | ---------------- |
| /          | local search       |                  |
| <leader>/  | global search      |                  |
| <leader>\* | cursor word search |                  |
| <leader>e  | search replace     |                  |
| <leader>rn | rename (lsp)       |                  |
| <C-L>      | clear search       |                  |
| K          | move line up       |                  |
| J          | move line down     |                  |

### Git

| Mapping       | Functionality      | Replaced Mapping             |
| ------------- | ------------------ | ---------------------------- |
| `<leader>hb`  | git blame          |                              |
| `<leader>hs`  | state hunk         | :Gitsigns stage_hunk         |
| `<leader>hu`  | undo state hunk    | :Gitsigns undo_stage_hunk    |
| `<leader>hr`  | reset hunk         | :Gitsigns reset_hunk         |
| `<leader>hR`  | reset buffer       | :Gitsigns reset_buffer       |
| `<leader>hp`  | preview hunk       | :Gitsigns preview_hunk       |
| `<leader>hS`  | state buffer       | :Gitsigns state_buffer       |
| `<leader>hU`  | reset buffer index | :Gitsigns reset_buffer_index |
| `<leader>gs`  | git status         | :Git                         |
| `<leader>gc`  | git commit         | :Gcommit -v                  |
| `<leader>ga`  | git add -p         | :Git add -p                  |
| `<leader>gm`  | git commit --amend | :Gcommit --amend             |
| `<leader>gp`  | git push           | :Gpush                       |
| `<leader>gd`  | git diff           | :Gdiff                       |
| `<leader>gw`  | write and git add  | :Gwrite                      |
| `<leader>gbr` | open github        | :GBrowse                     |

### Tmux

| Mapping      | Functionality                                | Replaced Mapping         |
| ------------ | -------------------------------------------- | ------------------------ |
| `<leader>vp` | Prompt for a command to run                  | :VimuxPromptCommand<CR>  |
| `<leader>vl` | Run last command executed by VimuxRunCommand | :VimuxRunLastCommand<CR> |
| `<leader>vi` | Inspect runner pane                          | :VimuxInspectRunner<CR>  |
| `<leader>vz` | " Zoom the tmux runner pane                  | :VimuxZoomRunner<CR>     |

### Misc

| Mapping      | Functionality          | Replaced Mapping |
| ------------ | ---------------------- | ---------------- |
| `<leader>r`  | reload nvim config     |                  |
| `<leader>x`  | quick save             |                  |
| `<leader>w`  | quick write            |                  |
| `<leader>q`  | quick quit             |                  |
| `ff`         | format                 |                  |
| `<leader>jk` | escape                 | Esc              |
| `<leader>a`  | Select all             | ggVG             |
| `yob`        | toogle background      |                  |
| `w!!`        | write in sudo mode     |                  |
| `<C-L>`      | clear search highlight | :nohlsearch      |
| `H`          | jump high              | Default          |
| `M`          | jump middle            | Default          |
| `L`          | jump low               | Default          |
| `<leader>2`  | execute current file   |                  |
| `<leader>z`  | zen mode               |                  |

# Others

- https://github.com/necolas/dotfiles
- https://github.com/sarrost/dotfiles
- https://github.com/simonsmith/dotfiles
- https://github.com/nicknisi/dotfiles
