

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
alias gs="git status"
alias week='date +%V' # Get week number
alias reload="exec $SHELL -l" # Reload the shell (i.e. invoke as a login shell)
alias path='echo $PATH | tr -s ":" "\n"' # Pretty print the path
alias cat='bat' # Drop-in replacement for cat
alias tms='~/.dotfiles/scripts/tmux-setup.sh' # tmux setup
alias tmp=' cd $(mktemp -d)'
alias pbcopy='xclip -selection clipboard' # replicate pbcopy from macos
alias pbpaste='xclip -selection clipboard -o'
alias x=exit
alias t=tmux
alias v=vim

# ls
TREE_IGNORE="cache|log|logs|node_modules|vendor"
alias ls=' exa --group-directories-first'
alias la=' ls -a'
alias ll=' ls --git -l'
alias lt=' ls --tree -D -L 2 -I ${TREE_IGNORE}'
alias ltt=' ls --tree -D -L 3 -I ${TREE_IGNORE}'
alias lttt=' ls --tree -D -L 4 -I ${TREE_IGNORE}'
alias ltttt=' ls --tree -D -L 5 -I ${TREE_IGNORE}'

if command -v nvim &> /dev/null; then
  alias vim=nvim # Use `\vim` or `command vim` to get the real vim.
fi
