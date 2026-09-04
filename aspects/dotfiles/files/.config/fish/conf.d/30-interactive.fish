if status is-interactive
  set fish_greeting

  mise activate fish | source

  # if command -q starship; starship init fish | source; end
  if command -q zoxide; zoxide init fish | source; end
  if command -q direnv; direnv hook fish | source; end
  if command -q scmpuff; scmpuff init -s --shell=fish | source; end
  if command -q fnox; fnox activate fish | source; end

end
