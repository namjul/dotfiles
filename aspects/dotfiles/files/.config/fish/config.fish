#
#  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗    ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝    ██╔════╝██║██╔════╝██║  ██║
# ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗   █████╗  ██║███████╗███████║
# ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║   ██╔══╝  ██║╚════██║██╔══██║
# ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝██╗██║     ██║███████║██║  ██║
#  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
#

# TODO: [omacom-io/omarchy-fish](https://github.com/omacom-io/omarchy-fish)
if status is-login
  bass source ~/.profile
end

if not type -q shellfirm
  # show this message to the user and don't register to terminal hook
  # we want to show the user that he not protected with `shellfirm`
  echo "`shellfirm` binary is missing. see installation guide: https://github.com/kaplanelad/shellfirm"
end

# Set Lenovo Trackpoint Speed
if command -q xinput; and xinput list-props "TPPS/2 Synaptics TrackPoint" > /dev/null 2>&1
  xinput set-prop "TPPS/2 Synaptics TrackPoint" "libinput Accel Speed" -0.5
end

mise activate fish | source

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

  if command -q starship; starship init fish | source; end
  if command -q zoxide; zoxide init fish | source; end
  if command -q direnv; direnv hook fish | source; end
  if command -q scmpuff; scmpuff init -s --shell=fish | source; end
  if command -q fnox; fnox activate fish | source; end

  # Tmux
  if command -v tmux > /dev/null 2>&1; and test "$TERM_PROGRAM" != ghostty
    set -gx SHELL (status fish-path)
    test -z $TMUX && tmux new-session;
  end

  if type -q shellfirm
    function checkShellFirm --on-event fish_preexec
      stty sane
      shellfirm pre-command --command "$argv"
      commandline -f execute
    end
  end

end

function fish_should_add_to_history
    for cmd in tomb
         string match -qr "^$cmd" -- $argv; and return 1
    end
    return 0
end

# function load_gitconfig_profile --on-variable PWD --description 'Load git config profile'
#   if git status &>/dev/null
#     set custom_repo_hosts "gitlab.tools.wienfluss.net|git-dev.rz.babiel.com" 
#     set git_url (git remote get-url origin)
#     set current_host (string match -r $custom_repo_hosts $git_url)
#     switch $current_host
#       case "mybenni"
#         echo "Load git config profile for selfhosted gitlab"
#       case "wienfluss"
#         git config include.path "~/.gitconfig_wienfluss"
#         echo "Load git config profile for wienfluss gitlab"
#       case "babiel"
#         git config include.path "~/.gitconfig_babiel"
#         echo "Load git config profile for babiel gitlab"
#     end
#     echo $git_url
#     echo $current_host
#   else
#     echo "No git repository found in current directory"
#   end
# end
