
# Make vim the default editor
export VISUAL="vim"
export EDITOR="$VISUAL"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# todo.text-cli
export TODOTXT_CFG_FILE="$HOME/.todo.cfg"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{.git}" 2> /dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --inline-info --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

