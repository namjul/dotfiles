function bat --wraps bat --description 'bat with theme from theme-mode state'
  set -l theme gruvbox-light
  if test -f "$HOME/.local/state/bat-theme"
    set theme (command cat "$HOME/.local/state/bat-theme")
  end
  command bat --theme="$theme" $argv
end
