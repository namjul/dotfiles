
function fdo --description "Fuzzy find & vim"
  # check if fzf was aborted
  if test (count $argv) -gt 0
    command $EDITOR $argv
  else
    fzf -m | xargs -o $EDITOR
  end
  commandline -f repaint
end
