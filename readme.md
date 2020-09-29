
# dotfiles ⛰

## Parts

- list of [software i use](scripts/brew)
- globally installed [npm packages](dots/default-npm-packages)
- [vim config](dots/vimrc)
- [tmux config](dots/tmux.conf)
- [alacritty](dots/alacritty.yml)
- [aliases](shell/alias.fish), [functions](shell/functions.fish) and [fish configuration](dots/fish/config.fish)
- [gitconfig](dots/gitconfig)
- [starship](https://starship.rs/) [config](dots/starship.toml)
- [install script](install)

## Installation

Clone dotfiles to home directory
```
git clone https://github.com/namjul/dotfiles
```

Run install script
```
./install
```

## Fonts
- https://github.com/cseelus/monego *
- https://github.com/tonsky/FiraCode
- https://monolisa.dev/

## Keyboard shortcuts

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

## Todos
- [ ] setup tiling windows manager again (https://www.youtube.com/watch?v=xnREqY-oyzM)
- [x] jump-list 
  - https://medium.com/breathe-publication/understanding-vims-jump-list-7e1bfc72cdf0
- [x] improve tmux settings
  - https://www.youtube.com/watch?v=N0RL_J0LT9A
  - [x] improve tmux copy-mode selection to clipboard
    - https://www.youtube.com/watch?v=ogeVqNOStQs&t=191s
    - https://superuser.com/questions/395158/tmux-copy-mode-select-text-block
- [ ] color for man pages
- [ ] build own statusline
  - vim filename should include folder
  - https://irrellia.github.io/blogs/vim-statusline/
  - https://shapeshed.com/vim-statuslines/
  - https://hackernoon.com/the-last-statusline-for-vim-a613048959b2
  - https://www.youtube.com/watch?v=Bsg-43PitrM
  - https://www.youtube.com/watch?v=hdgovJPDXV8
- [ ] implement colorscheme switcher
  - https://github.com/wincent/wincent/blob/268bca998c940f2434b657d7499f13359045e062/roles/dotfiles/files/.vim/after/plugin/color.vim#L11
  - https://github.com/wincent/wincent/blob/2e4447ddfea1d967196eaf118bcc08fbd848dabd/roles/dotfiles/files/.zsh/colors#L43
  - https://github.com/aaron-williamson/base16-alacritty/tree/master/colors
  - https://github.com/chriskempson/base16-vim/tree/master/colors
  - https://github.com/alacritty/alacritty/issues/472#issuecomment-531120265
- [ ] improve search highlight (different for active and matches)
  - https://github.com/wincent/loupe/issues/4
- [ ] fix "clipboard: error: Error: target STRING not available"
  - https://github.com/svermeulen/vim-yoink/issues/16
- [ ] learn about https://en.wikipedia.org/wiki/GNU_Readline
- [x] disable typescript checks in flow files
- [ ] make :Rg search through node_modules
- [ ] closetag in mdx files
- [x] closetag in typescript files
- [ ] open nerdtree with cursor at last active buffer
- [x] repair jump commands Ctrl-O / Ctrl-I
- [ ] give zsh with http://getantibody.github.io/ a try
- [ ] adjust dotfiles update process (https://github.com/caarlos0/dotfiles/blob/master/bin/dot_update)
- [ ] research https://0x46.net/thoughts/2019/02/01/dotfile-madness/
- [ ] build a dotfiles script in bash https://github.com/necolas/dotfiles/blob/master/bin/dotfiles
- [x] switch to fish
- [ ] create backup script https://github.com/necolas/dotfiles/blob/master/bin/backup
- [ ] create git bindings https://junegunn.kr/2016/07/fzf-git/
- [ ] expand aliases https://github.com/sh78/dotfiles/blob/d42cf1b86473e42ae123dffe38750eeaa31add99/.config/omf/aliases.load#L1
- [x] `npm run` autocomplete
- [x] optimize brew/asdf sourcing to speedup startup
- [ ] go through https://www.youtube.com/watch?v=JFr28K65-5E to find some vim config improvents
- [ ] try out https://github.com/dylanaraps/fff
- [ ] fix open command

# Inspiration

## Vim

- https://gist.github.com/jackkinsella/aa7374a6832cca8a09eadc3434a33c24
- https://github.com/wincent/wincent/tree/master/roles/dotfiles/files/.vim
