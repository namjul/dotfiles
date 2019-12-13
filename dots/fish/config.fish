
function setenv
  set -gx $argv
end

starship init fish | source
