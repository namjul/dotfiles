
# Make vim the default editor
export VISUAL="nvim"
export EDITOR="$VISUAL"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# todo.text-cli
export TODOTXT_CFG_FILE="$HOME/.todo.cfg"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs 2> /dev/null'
export FZF_DEFAULT_OPTS='--cycle --layout=reverse --border --height 75% --preview-window=wrap'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --null | xargs -0 dirname | sort | uniq"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

#neovide
export NEOVIDE_MULTIGRID="true"



# Set env variable with fallback
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -q XDG_DATA_HOME; or set -x XDG_DATA_HOME $HOME/.local/share
set -q XDG_CONFIG_HOME; or set -x XDG_CONFIG_HOME $HOME/.config

