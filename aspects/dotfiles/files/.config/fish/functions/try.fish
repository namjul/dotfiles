function try --description 'Jump into a dated try directory (evals try exec in this shell)'
  set -l tries_path $TRY_PATH
  if not set -q TRY_PATH
    set tries_path $HOME/code/tries
  end

  set -l out (command try exec --path $tries_path $argv 2>/dev/tty | string collect)
  if test $pipestatus[1] -eq 0
    eval $out
  else
    echo $out
  end
end
