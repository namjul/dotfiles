# Workflow
- opening files
  * `:GBrowser` to open file on github repo
  * `gx` open url in default browser
  * `-` open file explorer

## Todos
- [ ] refactor vimrc https://stackoverflow.com/questions/16082991/vim-switching-between-files-rapidly-using-vanilla-vim-no-plugins
- [ ] make spellchecking work
- [ ] add command to translate word under cursor using `trans`
- [ ] move vim-sensible into `vimrc`
- [ ] remove `sheerun/vim-polyglot`
- [ ] make use of folding https://vim.fandom.com/wiki/Make_views_automatic
  - https://github.com/wincent/wincent/blob/master/aspects/vim/files/.vim/lua/wincent/autocmds.lua#L125
- [ ] integrate cheat sheet workflow
  - https://github.com/chubin/cheat.sh
  - https://github.com/dbeniamine/cheat.sh-vim
  -  https://www.youtube.com/watch?v=DNiGoVohCmw&t=209s
- [ ] improve visual-mode colors and diagnostic colors https://www.youtube.com/watch?v=GrnBXhsr0ng
- [ ] finish up fish configuration
  - [ ] make use of git functions
  - [ ] finish up fish completions
  - [ ] vim mode
  - [ ] add ctrl-o key-binding to open with $EDITOR
  - [ ] create git bindings https://junegunn.kr/2016/07/fzf-git/
- [ ] expand aliases https://github.com/sh78/dotfiles/blob/d42cf1b86473e42ae123dffe38750eeaa31add99/.config/omf/aliases.load#L1
- [ ] go through https://www.youtube.com/watch?v=JFr28K65-5E to find some vim config improvents
- [ ] make :Rg search through node_modules
- [ ] fix "clipboard: error: Error: target STRING not available"
  - https://github.com/svermeulen/vim-yoink/issues/16
- [ ] improve search highlight (different for active and matches)
  - https://github.com/wincent/loupe/issues/4
- [ ] closetag in mdx files
- [ ] use vim plugin Tabable for aligning markdown tables
- [ ] settle on a file explorer(ranger, lf, fff, vifm)
  - [ ] try out https://github.com/dylanaraps/fff
- [ ] setup tiling windows manager again (https://www.youtube.com/watch?v=xnREqY-oyzM)
- [ ] hide mouse cursor
- [ ] color for man pages
  - [ ] vim filename should include folder
- [ ] implement colorscheme switcher
  - https://github.com/wincent/wincent/blob/268bca998c940f2434b657d7499f13359045e062/roles/dotfiles/files/.vim/after/plugin/color.vim#L11
  - https://github.com/wincent/wincent/blob/2e4447ddfea1d967196eaf118bcc08fbd848dabd/roles/dotfiles/files/.zsh/colors#L43
  - https://github.com/aaron-williamson/base16-alacritty/tree/master/colors
  - https://github.com/chriskempson/base16-vim/tree/master/colors
  - https://github.com/alacritty/alacritty/issues/472#issuecomment-531120265
- [ ] make dotfiles script
  - build a dotfiles script in bash https://github.com/necolas/dotfiles/blob/master/bin/dotfiles
  - adjust dotfiles update process (https://github.com/caarlos0/dotfiles/blob/master/bin/dot_update)
  - https://github.com/eli-schwartz/dotfiles.sh/blob/master/dotfiles
- [ ] add text snippets for fast writing https://medium.com/@nikitavoloboev/write-once-never-write-again-c2fa1f6c4e8
- [ ] consider moving from homebrew to nix
- [ ] create backup script https://github.com/necolas/dotfiles/blob/master/bin/backup
- [ ] setup neomut
- [ ] correct git message syntax highlighting https://shime.sh/git-commit-message-syntax-highlighting-in-vim
- [ ] add [`SpaceFN`](https://geekhack.org/index.php?topic=51069.0) layout to keyboard
- [ ] automaticall build readme content from source files using tree-sitter
- [ ] replace fzf with [telescope](https://www.youtube.com/watch?v=2tO2sT7xX2k)
  - [ ] replacement on resize vim window
- [ ] switch from ale to lsp
  -  https://github.com/mfussenegger/nvim-lint/
- [ ] fzf
  - [ ] https://github.com/stsewd/fzf-checkout.vim
  - [ ] simplify fzf code
    - my alfred solution
  - [ ] create shortscuts to directories using `fzf`
  - [ ] vim command open all files from filtered fzf output
- [ ] create own snippets library (only what i need)
  - [ ] markdown snippets
  - [ ] frontmatter
  - [ ] javascript
  - [ ] typescipt
  - [ ] lua
- [ ] close preview window on auto-complete https://stackoverflow.com/questions/3105307/how-do-you-automatically-remove-the-preview-window-after-autocompletion-in-vim
- [ ] consider replacing `asdf` `nodejs` with [fnm](https://github.com/Schniz/fnm)
  - Inspiration: https://github.com/starship/starship/issues/2220
- updates
  * update fisher https://github.com/jorgebucaran/fisher/issues/652
- fixes
  - [ ] **opening directories with neovim**
  - [ ] exiting neovim takes long time
  - [ ] enhance startuptime
  - [ ] crontab.md should have `markdown` ft
  - [ ] improve fish vim mode delay https://github.com/fish-shell/fish-shell/issues/5894
  - [ ] save undo sessions
  - [ ] make deople autocomplete work on jsx prop types
  - [ ] typescript autocomplete not showing relevant options or too much
- [X] use https://github.com/csexton/trailertrash.vim
- [X] setup `ToggleWrap` function
- [x] `npm run` autocomplete
- [x] optimize brew/asdf sourcing to speedup startup
- [x] switch to fish
- [x] closetag in typescript files
- [x] repair jump commands Ctrl-O / Ctrl-I
- [x] disable typescript checks in flow files
- [x] jump-list
  - https://medium.com/breathe-publication/understanding-vims-jump-list-7e1bfc72cdf0
- [x] improve tmux settings
- [x] fix open command
  - https://www.youtube.com/watch?v=N0RL_J0LT9A
  - [x] improve tmux copy-mode selection to clipboard
    - https://www.youtube.com/watch?v=ogeVqNOStQs&t=191s
    - https://superuser.com/questions/395158/tmux-copy-mode-select-text-block
- [X] build own statusline
- research
  - learn how to make a plugin https://www.youtube.com/watch?v=apyV4v7x33o
  - https://0x46.net/thoughts/2019/02/01/dotfile-madness/
  - learn about https://en.wikipedia.org/wiki/GNU_Readline
  - learn about the differences of `find` and `locate`
- checkout
  * cli tools https://github.com/nikitavoloboev/my-mac-os#command-line-apps
  - give zsh with http://getantibody.github.io/ a try
  - give https://taskwarrior.org/ a try
  - give `dyng/ctrlsf.vim` a try
  - dotfiles
    * https://github.com/nikitavoloboev/dotfiles
  - consider https://github.com/tpope/vim-abolish
  - watch https://www.youtube.com/watch?v=N9UZNhcNRCQ&list=PLDJwwFOUm0KquQvDZGVfPsPLrnlbbXtXB
  - try https://github.com/volta-cli/volta
  - https://thoughtbot.com/blog/faster-grepping-in-vim
  - https://github.com/mizlan/dots-nightly/blob/lua-port/lua/plugins.lua
  - https://alexpearce.me/2016/02/managing-dotfiles-with-stow/
    - https://github.com/momofor/dotfiles | https://www.youtube.com/watch?v=_GldsqYpYz0
  - https://github.com/s1n7ax/dotnvim | https://www.youtube.com/watch?v=n4yHEqBZ8Mk
  - https://github.com/npxbr/gruvbox.nvim
  - https://github.com/Kethku/neovide
  - Vim
    * plugins from wincent https://github.com/wincent/wincent/tree/master/aspects/vim/files/.vim/pack/bundle/opt
    * https://gist.github.com/jackkinsella/aa7374a6832cca8a09eadc3434a33c24
    * https://github.com/wincent/wincent/tree/master/roles/dotfiles/files/.vim
    * https://github.com/codota/tabnine-vim
    * https://github.com/tpope/vim-projectionist for alternating files
  - [Vim task management with syncint to TaskWarrior](https://github.com/samgriesemer/vim-roam-task)
  - [Setup global shortscuts with espanso](https://espanso.org/)
  - https://github.com/thaerkh/vim-workspace
- shortcut to dropbox link
- add personal-wiki quotes to startifies `g:startify_custom_header_quotes`

## To watch
- [ ] [intro into tmux - sessions, windows, panes, and commands, and how to use tmux](https://www.youtube.com/watch?v=NZO8KjNbwJk)
- [ ] [Vim Tips You Probably Never Heard of](https://www.youtube.com/watch?v=bQfFvExpZDU)

## notetaking lua plugin

### features

- Peek? and Go to Definition for `[[wiki-links]]`
  * https://github.com/samgriesemer/vim-roam-md
- Create New Note On Missing Go To Definition
- Autocompletion for Wiki Links (uniqueFilenames, relativePaths)
- Backlink Explorer
- Syntax Highlighting for Tags and Wiki Links
- Peek References to Wiki Links
- Peek References to Tags
- Find All References to Wiki Links
- Find All References to Tag
- Search Workspace for Notes with Tag
- New Note Command
- daily notes [https://foambubble.github.io/foam/daily-notes]
- Ultisnips shortcut for wiki-links `h`
- Command to append txt to inbox
- paste image to markdown https://github.com/ferrine/md-img-paste.vim

### lua
- https://github.com/nanotee/nvim-lua-guide
- Make a Simple Vim/Neovim Plugin from Scratch: cyclist.vim https://www.youtube.com/watch?v=apyV4v7x33o&t=162s

### research
- https://github.com/Alok/notational-fzf-vim
- How to Use Roam to Outline a New Article in Under 20 Minutes
  https://www.youtube.com/watch?v=RvWic15iXjk
- foam
  https://foambubble.github.io/foam/recipes
- Obsidian App
  https://obsidian.md/
- Personal notetaking in Vim
  https://vimways.org/2019/personal-notetaking-in-vim/
- Graph of markdown links
  https://github.com/tchayen/markdown-links
- wiki links support in vim markdown plugin
  https://github.com/plasticboy/vim-markdown/pull/478
- Markdown Notes
  https://github.com/kortina/vscode-markdown-notes
- Markdown pandoc notes
  https://jamesbvaughan.com/markdown-pandoc-notes/
- Pervane - Plain text file based note taking and knowledge base building tool, markdown editor, simple browser IDE
  https://github.com/hakanu/pervane
- dendron
  https://dendron.so/
