
function fdo --description "Fuzzy find & vim"
  if test (count $argv) -gt 0
    command $EDITOR $argv
  else
    fzf -m | xargs -o $EDITOR
  end
end
