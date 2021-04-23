
# dotfiles ⛰

## Parts

- list of [software i use](scripts/brew)
- globally installed [npm packages](dots/default-npm-packages)
- [neovim](dots/.config/nvim/init.lua)
- [tmux config](dots/tmux.conf)
- [alacritty](dots/alacritty.yml)
- [gitconfig](dots/gitconfig)
- [fish configuration](dots/.config/fish/config.fish)
- [aliases](shell/alias.fish), [functions](shell/functions.fish)
- [starship](dots/starship)
- [espanso](dots/.config/espanso/default.yml)
- [zathura](dots/.config/zathura/zathurarc)
- [ripgrep](dots/.ripgreprc)
- [ripgrep](dots/.ripgreprc)

![Screenshot](screenshot.png)

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

### Fonts

Install a font of your choice
- https://github.com/cseelus/monego *
- https://github.com/tonsky/FiraCode
- https://monolisa.dev/
- https://coding-fonts.css-tricks.com/fonts/anonymous-pro/
- https://github.com/ryanoasis/nerd-fonts
- Ascii Art "ANSI Shadow" https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=bashrc

## Vim Keyboard shortcuts

**Legend**
`,`== leader key
`C` == ctrl key

| Mapping | Functionality                                                              | Replaced Mapping |
| ------- | -------------------------------------------------------------------------- | ---------------- |
| `,r`   | reload nvim config                                                            | None             |
| `,s`   | quick save                                                                    | None             |
| `,w`   | quick write                                                                    | None             |
| `,f`   | format                                                                        | :ALEFix             |
| `,n`   | open `vaffle` file explorer                                                     | None             |
| `,jk`  | escape                                                                        | Esc             |
| `,/`   | search in project folder                                                       | :Ag<CR> |
| `,*`  | search word under cursor in project folder                                  | :Ag <C-R><C-W><CR> |
| `,a`   | Select all                                                                    | ggVG |
| `,evr` | edit vimrc                                                                    | :<C-U>edit ~/.vimrc<CR> |
| `,bg`  | toogle background                                                             | None
| `,gb`  | git blame                                                                     | :Gblame<cr> |
| `,gs`  | git status                                                                    | :Gstatus<cr> |
| `,gc`  | git commit                                                                    | :Gcommit -v<cr> |
| `,ga`  | git add -p                                                                    | :Git add -p<cr> |
| `,gm`  | git commit --amend                                                            | :Gcommit --amend<cr> |
| `,gp`  | git push                                                                      | :Gpush<cr> |
| `,gd`  | git diff                                                                      | :Gdiff<cr> |
| `,gw`  | git ...                                                                       | :Gwrite<cr> |
| `,vp`  | Prompt for a command to run                                                   | :VimuxPromptCommand<CR> |
| `,vl`  | Run last command executed by VimuxRunCommand                                  | :VimuxRunLastCommand<CR> |
| `,vi`  | Inspect runner pane                                                           | :VimuxInspectRunner<CR> |
| `,vz`  | " Zoom the tmux runner pane                                                 | :VimuxZoomRunner<CR> |
| `w!!` | write in sudo mode | None |
| `<C-L>` | clear search highlight | :nohlsearch |:spv
| `H` | jump high | Default |
| `M` | jump middle | Default |
| `L` | jump low | Default |

# Inspiration

- https://github.com/necolas/dotfiles
- https://github.com/sarrost/dotfiles
- https://github.com/simonsmith/dotfiles
