
##############################################################################
# 02. ALIASES                                                                #
##############################################################################

# quick switches to folders
abbr dd 'cd $HOME/.dotfiles'
abbr db 'cd ~/Dropbox'
abbr dc 'cd ~/code'
abbr dls 'cd ~/.local/share'

# quick edits
alias e $EDITOR
alias ev 'nvim ~/.dotfiles/dots/.config/nvim/init.lua'
alias ed 'nvim ~/.dotfiles/dots/'
alias ef 'nvim ~/.dotfiles/dots/.config/fish/config.fish'
alias et 'nvim ~/Dropbox/todo'

abbr d cd
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'
abbr ..... 'cd ../../../..'
abbr --add -- - 'cd -'

abbr h 'history'
abbr j 'jobs'
abbr l 'less -R'

abbr mv 'mv -i'
abbr cp 'cp -i -p'
abbr grep 'grep --color=auto'
abbr g 'git'
abbr week 'date +%V' # Get week number
abbr path 'echo $PATH | tr -s " " "\n"' # Pretty print the path
alias cat="bat" # Drop-in replacement for cat TODO add  --theme=gruvbox-(set-colorscheme) but a fast implementation
abbr tmp ' cd (mktemp -d)'
abbr pbcopy 'xclip -selection clipboard' # replicate pbcopy from macos
abbr pbpaste 'xclip -selection clipboard -o'
abbr x exit
abbr t todo
abbr tw timew
abbr tws timew start
abbr twsum timew summary :annotation :ids :week
abbr en 'trans :en'
abbr de 'trans :de'
abbr grn 'git rebase -i HEAD~' # git interactive rebase to n
abbr run 'dum run' # shorthand for npm run
abbr nv 'node --version'
abbr untar 'tar -xvf' # extract .tar.gz
abbr --add unset 'set --erase' # remove env variable
abbr repl 'NODE_PATH=(npm root -g) node'
abbr ts 'toggl start'
abbr tp 'toggl stop'
abbr tc 'toggl continue'
abbr tn 'toggl now'
abbr tsm 'toggl sum'
abbr tb "tmux new -s (pwd | sed 's/.*\///g')" # begin tmux session

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
