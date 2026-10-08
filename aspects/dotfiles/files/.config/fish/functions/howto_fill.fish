# TODO https://github.com/yurenchen000/howto.sh/blob/main/howto.sh

function howto_fill --description 'Replace the command line with an LLM command suggestion'
  set -l query (commandline)
  if test -z "$query"
    return 1
  end

  set -l answer (howto-suggest -- $query)
  if test $status -ne 0 -o -z "$answer"
    return 1
  end

  commandline -r -- $answer
  commandline -f repaint
end
