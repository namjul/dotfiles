#
#  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗    ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝    ██╔════╝██║██╔════╝██║  ██║
# ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗   █████╗  ██║███████╗███████║
# ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║   ██╔══╝  ██║╚════██║██╔══██║
# ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝██╗██║     ██║███████║██║  ██║
#  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
#

if status is-login
  bass source ~/.profile
end

# notify if brew command does not exists
if ! type -q brew
  echo "Make sure `brew` command is available."
end

if status is-interactive
  set fish_greeting # remove fish's greeting

  # load
  set parts functions env path alias
  for part in $parts
    set file $HOME/.dotfiles/shell/$part.fish
    if test -e $file
      source $file
    end
  end

  if not set --query fzf_fish_custom_keybindings
    set --universal fzf_fish_custom_keybindings
  end

  # Tmux
  if command -v tmux > /dev/null 2>&1
     test -z $TMUX && tmux new-session -A -s main;
  end

  starship init fish | source
end
