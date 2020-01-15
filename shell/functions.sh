
##############################################################################
# 03. FUNCTIONS                                                              #
##############################################################################

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$@"
}

# Open file from terminal
# USAGE: open <FILE>
function open() {
  echo $1
  xdg-open $1 </dev/null &>/dev/null &
}

# Add to path
prepend-path() {
  [ -d $1 ] && PATH="$1:$PATH"
}

# git interactive rebase to n
grn() { 
  git rebase -i HEAD~"$1"; 
}


# tm - create new tmux session, or switch to existing one. Works from within tmux too.
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
