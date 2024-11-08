
function fzf_change_directory -d "Change directory"
  most-wanted-dirs | fzf | read foo -l

  if [ $foo ]
    builtin cd $foo
    commandline -r ''
    commandline -f repaint
  else
    commandline ''
  end
end
