## Installation

Clone dotfiles to home directory
```
git clone https://github.com/namjul/dotfiles
```

Run install script
```
./install
```

## Manual steps 
- Install [alacritty](https://github.com/jwilm/alacritty)
- Install [xcape](https://github.com/alols/xcape) 
- Set caps lock to ctrl http://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-escctrl:nocaps
- Run `setxkbmap -option ctrl:nocaps` && `xcape -e 'Control_L=Escape'` at startup
- Run `xset r rate 200 30` at startup
- Setup font https://github.com/tonsky/FiraCode

## Todos
- [ ] add LSP support
  - https://github.com/autozimu/LanguageClient-neovim
  - https://github.com/Shougo/deoplete.nvim
  - https://github.com/dense-analysis/ale / https://github.com/desmap/ale-sensible / https://github.com/neoclide/coc.nvim/issues/348#issuecomment-454790599
- [ ] build own statusline
  - vim filename should include folder
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
- [ ] add floating windows for fzf
  - https://github.com/yuki-ycino/fzf-preview.vim
  - https://github.com/Blacksuan19/init.nvim/blob/master/init.vim#L327
- [x] tmux/vim file change reloading
- [w] enhance mappings (normal, command, visual, leader)
- [x] window splits "vinegar"
  https://www.youtube.com/watch?v=OgQW07saWb0
- [x] jump-list 
  - https://medium.com/breathe-publication/understanding-vims-jump-list-7e1bfc72cdf0
- [x] improve tmux settings
  - https://www.youtube.com/watch?v=N0RL_J0LT9A
  - [x] improve tmux copy-mode selection to clipboard
    - https://www.youtube.com/watch?v=ogeVqNOStQs&t=191s
    - https://superuser.com/questions/395158/tmux-copy-mode-select-text-block
- [x] improve search highlight (different for active and matches)
- [x] adjust fzf open active item command to from x/v to s/v
- [ ] move tmux statusbar to the bottom
- [ ] fix "clipboard: error: Error: target STRING not available"
  - https://github.com/svermeulen/vim-yoink/issues/16


# Vim

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
