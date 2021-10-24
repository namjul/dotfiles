
function fdo --description "Fuzzy find & open"

  # list of extensions that should be opened with preferred application
  set ext_exceptions 'pdf'

  fzf | read -l result

  if [ -n "$result" ]
    set ext (string split -r -m1 '.' $result)

    if not contains $ext[2] $ext_exceptions
      command $EDITOR $result
    else
      open $result
    end
  end

  commandline -f repaint
end
