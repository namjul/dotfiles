function is_in_git_repo
  git rev-parse --git-dir > /dev/null 2>&1
end

function fzf-down
  fzf --height 50% $argv --border --ansi
end
