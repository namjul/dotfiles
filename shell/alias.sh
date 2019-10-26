

##############################################################################
# 02. ALIASES                                                                #
##############################################################################

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"
alias cdd="cd \"\${DOTFILES}\""

# Shortcuts
alias d="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias h="history"
alias j="jobs"

alias l='less'
alias mv='mv -i'
alias cp='cp -i -p'
alias ls='ls -abp --color=auto'
alias grep='grep --color=auto'

# git
alias g="git"
alias g-="git checkout -"
alias gb="git branch --verbose"
alias gi="git ink"
alias gg="git grep --line-number --break --heading"
alias gl="git l --max-count 50"
alias gll="git ll --max-count 50"
alias gp="git push"
alias gpo="git push origin"
alias gs="scmpuff_status"

# Color LS
# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi
alias ls="command ls ${colorflag}"
alias l="ls -lF ${colorflag}" # all files, in long format
alias la="ls -laF ${colorflag}" # all files inc dotfiles, in long format
alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories


# Enable aliases to be sudo’ed
alias sudo='sudo '

# Gzip-enabled `curl`
alias gurl='curl --compressed'

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Colored up cat!
# You must install Pygments first - "sudo easy_install Pygments"
alias c='pygmentize -O style=monokai -f console256 -g'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# todo.text-cli
alias t='todo -d $HOME/.todo.cfg'

# This actually happens a lot
alias :q='exit'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Drop-in replacement for cat
alias cat='bat'

# tmux setup
alias tms='~/.dotfiles/scripts/tmux-setup.sh'
