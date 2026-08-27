function gwd --description 'Remove the current linked git worktree and its branch'
  set -l git_dir (realpath (git rev-parse --git-dir))
  or return 1
  set -l common (realpath (git rev-parse --git-common-dir))
  if test "$git_dir" = "$common"
    echo "This is the main worktree, not a linked one."
    return 1
  end

  set -l cwd (pwd)
  set -l branch (git rev-parse --abbrev-ref HEAD)
  set -l main (realpath "$common/..")

  read -P "Remove worktree and branch '$branch'? (y/N): " confirm
  if not string match -qr '^[Yy]$' -- $confirm
    return 0
  end

  cd $main
  git worktree remove $cwd --force
  or return 1
  git branch -D $branch
end
