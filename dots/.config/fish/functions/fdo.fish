
function fdo --description "Fuzzy find & vim"
  fzf | read -l result

  if [ -n "$result" ]
    command $EDITOR $result
  end

  commandline -f repaint
end
