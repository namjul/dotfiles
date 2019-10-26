
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
