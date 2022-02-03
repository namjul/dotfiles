
##############################################################################
# 02. ALIASES                                                                #
##############################################################################

# quick switches to folders
abbr dd 'cd $HOME/.dotfiles'
abbr db 'cd ~/Dropbox'
abbr dc 'cd ~/code'

# quick edits
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
abbr gs 'git status'
abbr week 'date +%V' # Get week number
abbr path 'echo $PATH | tr -s " " "\n"' # Pretty print the path
alias cat 'bat' # Drop-in replacement for cat
abbr tms "$HOME/.dotfiles/scripts/tmux-setup.sh" # tmux setup
abbr tmp ' cd (mktemp -d)'
abbr pbcopy 'xclip -selection clipboard' # replicate pbcopy from macos
abbr pbpaste 'xclip -selection clipboard -o'
abbr x exit
abbr t todo
abbr en 'trans :en'
abbr de 'trans :de'
abbr grn 'git rebase -i HEAD~ ' # git interactive rebase to n
abbr run 'npm run' # shorthand for npm run
abbr nv 'node --version'
abbr untar 'tar -xvf' # extract .tar.gz
abbr --add unset 'set --erase' # remove env variable

# ls
if type -q exa
  set TREE_IGNORE 'cache|log|logs|node_modules|vendor|.git'
  alias ls 'exa --icons'
  abbr la 'ls -a'
  abbr ll 'ls -l'
  abbr lla 'ls -l -a'
  abbr lt 'ls --tree -D -L 2 -I $TREE_IGNORE'
  abbr ltt 'ls --tree -D -L 3 -I $TREE_IGNORE'
  abbr lttt 'ls --tree -D -L 4 -I $TREE_IGNORE'
end

# vim
if command -v nvim &> /dev/null
  alias vim="nvim" # Use `\vim` or `command vim` to get the real vim.
  alias e vim
end

