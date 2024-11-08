
##############################################################################
# 02. ALIASES                                                                #
##############################################################################

# quick edits
alias e $EDITOR
alias ev 'nvim ~/.dotfiles/dots/.config/nvim/init.lua'
alias ed 'nvim ~/.dotfiles/dots/'
alias ef 'nvim ~/.dotfiles/dots/.config/fish/config.fish'
alias et 'nvim ~/Dropbox/todo'

# navigation
abbr d cd
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'
abbr ..... 'cd ../../../..'
abbr --add -- - 'cd -'
# quick switches to folders
abbr dd 'cd $HOME/.dotfiles'
abbr db 'cd ~/Dropbox'
abbr dc 'cd ~/code'
abbr dls 'cd ~/.local/share'

# shell
abbr h 'history'
abbr j 'jobs'
abbr -a L --position anywhere --set-cursor "% | less -R"
abbr x exit

# git
abbr g 'git'
abbr grn 'git rebase -i HEAD~' # git interactive rebase to n

# translation
abbr en 'trans :en'
abbr de 'trans :de'

# node
abbr repl 'NODE_PATH=(npm root -g) node'
abbr run 'dum run' # shorthand for npm run
abbr nr 'npm run' # shorthand for npm run
abbr nv 'node --version'

# timewarrior
abbr tw timew
abbr tws timew start
abbr twa timew annotate
abbr twc timew continue
abbr twsum timew summary :annotation :ids :week

# todo
abbr t todo
abbr ts 'toggl start'
abbr tp 'toggl stop'
abbr tc 'toggl continue'
abbr tn 'toggl now'
abbr tsm 'toggl sum'

# tmux
abbr tb "tmux new -s (pwd | sed 's/.*\///g')" # begin tmux session

# docker
abbr dcu "docker compose up"
abbr dsa "docker stop (docker ps -a -q)"

# misc
abbr mv 'mv -i'
abbr cp 'cp -i -p'
abbr grep 'grep --color=auto'
abbr week 'date +%V' # Get week number
abbr path 'echo $PATH | tr -s " " "\n"' # Pretty print the path
alias cat="bat" # Drop-in replacement for cat TODO add  --theme=gruvbox-(set-colorscheme) but a fast implementation
abbr tmp ' cd (mktemp -d)'
abbr untar 'tar -xvf' # extract .tar.gz
abbr --add unset 'set --erase' # remove env variable
abbr mr 'mise run' # run mise tasks

 # replicate pbcopy from macos
alias pbcopy 'xclip -selection clipboard'
alias pbpaste 'xclip -selection clipboard -o'
abbr pc 'pbcopy'
abbr pp 'pbpaste'

# IP addresses
abbr globalip "dig +short myip.opendns.com @resolver1.opendns.com"
abbr localip 'ip -o route get to 8.8.8.8 | sed -n "s/.*src \([0-9.]\+\).*/\1/p"'

# ls
if type -q eza
  set TREE_IGNORE 'cache|log|logs|node_modules|vendor|.git'
  alias ls 'eza --icons'
  abbr la 'ls -a'
  abbr ll 'ls -l'
  abbr lla 'ls -l -a'
  abbr lt 'ls --tree -D -L 2 -I $TREE_IGNORE'
  abbr ltt 'ls --tree -D -L 3 -I $TREE_IGNORE'
  abbr lttt 'ls --tree -D -L 4 -I $TREE_IGNORE'
end
