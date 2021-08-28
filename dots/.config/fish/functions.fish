
##############################################################################
# 03. FUNCTIONS                                                              #
##############################################################################

# Reload shell
function reload
  source ~/.config/fish/config.fish
end

# Create a new directory and enter it
function mkd
	mkdir -p "$argv" && cd "$argv"
end

# Open file from terminal
# USAGE: open <FILE>
function open
  xdg-open $argv[1]
end

# tm - create new tmux session, or switch to existing one. Works from within tmux too.
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.
function tm
  set -l change "attach-session"
  if test -n "$TMUX"
    set change "switch-client"
  end

  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux $change -t "$result"
end

function installNpmDefaults
    xargs -a ~/.default-npm-packages npm install -g
end

# Source: https://coderwall.com/p/grmruq/git-status-on-all-repos-in-folder
function repos --description="Git status on all repos in folder"
  find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(cd {} && [ -d .git ] && echo {} && git status -s && echo)' \;
end

function dsync --description="All dendron sync in current director"
  if type -q dendron
    repos
    read -l -P 'Do you want to continue? [y/N] ' confirm
    switch $confirm
      case Y y
        dendron workspace --wsRoot . sync
      case '' N n
        return 1
    end
  else
    echo "Make sure \`dendron\` command is available."
  end
end

# GIT heart FZF
# -------------

function is_in_git_repo
	git rev-parse --git-dir > /dev/null 2>&1
end

function fzf-down
  fzf --height 50% $argv --border --ansi
end

function gf
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
end

function gb
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort | \
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES | \
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
end

function gt
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
end

function gc
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
end

function gr
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -f1
end
