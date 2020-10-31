
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
- [x] repair jump commands Ctrl-O / Ctrl-I
- [ ] give zsh with http://getantibody.github.io/ a try
- [ ] research https://0x46.net/thoughts/2019/02/01/dotfile-madness/
- [ ] make dotfiles script
  - build a dotfiles script in bash https://github.com/necolas/dotfiles/blob/master/bin/dotfiles
  - adjust dotfiles update process (https://github.com/caarlos0/dotfiles/blob/master/bin/dot_update)
  - https://github.com/eli-schwartz/dotfiles.sh/blob/master/dotfiles
- [x] switch to fish
- [ ] create backup script https://github.com/necolas/dotfiles/blob/master/bin/backup
- [ ] create git bindings https://junegunn.kr/2016/07/fzf-git/
- [ ] expand aliases https://github.com/sh78/dotfiles/blob/d42cf1b86473e42ae123dffe38750eeaa31add99/.config/omf/aliases.load#L1
- [x] `npm run` autocomplete
- [x] optimize brew/asdf sourcing to speedup startup
- [ ] go through https://www.youtube.com/watch?v=JFr28K65-5E to find some vim config improvents
- [ ] try out https://github.com/dylanaraps/fff
- [ ] fix open command
- [ ] setup neomut
- [ ] give https://taskwarrior.org/ a try
- [ ] give `dyng/ctrlsf.vim` a try
- [ ] finish up fish configuration
  - [ ] make use of git functions
  - [ ] finish up fish completions
  - [ ] vim mode
  - [ ] add ctrl-o key-binding to open with $EDITOR
- [ ] exiting neovim takes long time
- [ ] learn how to make a plugin https://www.youtube.com/watch?v=apyV4v7x33o
- [ ] settle on a file explorer(ranger, lf, fff, vifm)
- [ ] consider https://github.com/tpope/vim-abolish
- [ ] watch https://www.youtube.com/watch?v=N9UZNhcNRCQ&list=PLDJwwFOUm0KquQvDZGVfPsPLrnlbbXtXB
- [ ] add command to translate word under cursor using `trans`
- [ ] make spellchecking work
- [ ] try https://github.com/volta-cli/volta


## notetaking lua plugin

### features

- Peek? and Go to Definition for `[[wiki-links]]`
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