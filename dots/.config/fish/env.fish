
# See: https://docs.brew.sh/Analytics
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTO_UPDATE_SECS="86400"

# Make vim the default editor
if command -v nvim &> /dev/null
  export EDITOR=(which nvim)
else if command -v vim &> /dev/null
  export EDITOR=(which vim)
end

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

# pnpm
set -gx PNPM_HOME "/home/nam/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# For now, requires a manual `cargo build --release`.
export SHELLBOT=$HOME/.config/nvim/pack/bundle/opt/shellbot/lua/target/release/shellbot
export SHELLBOT_PROMPT='
  You are a helpful assistant who provides brief explanations and short code
  snippets for technologies like TypeScript, JavaScript, Rust, HTML, CSS, Bash, Go and Lua. Your user is an expert programmer,
  so you should be concise. You do not show lengthy steps or setup instructions.
'

export KUBECONFIG="$HOME/.kube/config"
