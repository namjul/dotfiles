function _nr_completion
  set -l tokens (commandline -xpc)
  if test (count $tokens) -ge 1
    set tokens $tokens[2..-1]
  end
  nr --completion $tokens 2>/dev/null
end

complete -c nr -f -a '(_nr_completion)' -d 'package.json scripts'
