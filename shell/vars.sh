
# Make vim the default editor
export EDITOR="nvim"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

export DOTFILES="${HOME}/.dotfiles"
export SHELL_DOTFILES="${DOTFILES}/shell"

# todo.text-cli
export TODOTXT_CFG_FILE="$HOME/.todo.cfg"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git}"'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --inline-info --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ripgrep
export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"
