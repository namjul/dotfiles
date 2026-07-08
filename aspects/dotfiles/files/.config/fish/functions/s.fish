function s
  if test -z "$argv[1]"
    set -l path (string replace -r "^$HOME" "~" (pwd))
    echo -n $path | pbcopy
  else
    set -l path (string replace -r "^$HOME" "~" (realpath $argv[1]))
    echo -n $path | pbcopy
  end
end
