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

if not type -q brew
  # notify if brew command does not exists
  echo "Make sure `brew` command is available."
end

if not type -q shellfirm
  # show this message to the user and don't register to terminal hook
  # we want to show the user that he not protected with `shellfirm`
  echo "`shellfirm` binary is missing. see installation guide: https://github.com/kaplanelad/shellfirm"
end

# https://gist.github.com/dmccombs/6345e5b8319e3a060b64181c1784f567
# set (gnome-keyring-daemon --start | string split "=")

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
  # if command -v tmux > /dev/null 2>&1
  #    test -z $TMUX && tmux new-session;
  # end

  starship init fish | source
  zoxide init fish | source
  direnv hook fish | source
  # mise activate fish | source # already handled by homebrew
  # scmpuff init -s --shell=fish | source

  if type -q shellfirm
    function checkShellFirm --on-event fish_preexec
      stty sane
      shellfirm pre-command --command "$argv"
      commandline -f execute
    end
  end

end

# do not track `tomb` commands
# Source: https://github.com/fish-shell/fish-shell/issues/2788
function ignorehistory --on-event fish_prompt
    history --delete --prefix tomb
end
