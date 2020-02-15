

##############################################################################
# 02. ALIASES                                                                #
##############################################################################

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"
alias cdd="cd \"\${DOTFILES}\""
alias d="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias h="history"
alias j="jobs"
alias l='less'
alias mv='mv -i'
alias cp='cp -i -p'
alias grep='grep --color=auto'
alias g="git"
alias gs="git s"
alias ls='ls --color=auto'
alias l="ls -lF" # all files, in long format
alias la="ls -laF" # all files inc dotfiles, in long format
alias lsd='ls -lF | grep "^d"' # only directories
alias week='date +%V' # Get week number
alias reload="exec $SHELL -l" # Reload the shell (i.e. invoke as a login shell)
alias path='echo $PATH | tr -s ":" "\n"' # Pretty print the path
alias cat='bat' # Drop-in replacement for cat
alias tms='~/.dotfiles/scripts/tmux-setup.sh' # tmux setup
alias pbcopy='xclip -selection clipboard' # replicate pbcopy from macos
alias pbpaste='xclip -selection clipboard -o'
alias t=tmux
alias v=vim

if command -v nvim &> /dev/null; then
  alias vim=nvim # Use `\vim` or `command vim` to get the real vim.
fi
