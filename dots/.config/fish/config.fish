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
    set file $HOME/.config/fish/$part.fish
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
  thefuck --alias | source
  zoxide init fish | source
  direnv hook fish | source
  # scmpuff init -s --shell=fish | source
end

# do not track `tomb` commands
# Source: https://github.com/fish-shell/fish-shell/issues/2788
function ignorehistory --on-event fish_prompt
    history --delete --prefix tomb
end
