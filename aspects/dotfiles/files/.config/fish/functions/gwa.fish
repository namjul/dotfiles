function gwa --description 'Add a sibling git worktree named <repo>--<branch>'
  if test -z "$argv[1]"
    echo "Usage: gwa <branch>"
    return 1
  end

  set -l branch $argv[1]
  set -l base (basename $PWD)
  set -l slug (string replace -a '/' '-' -- $branch)
  set -l wt_path "../$base--$slug"

  git worktree add -b $branch $wt_path
  or return 1
  mise trust $wt_path
  cd $wt_path
end
