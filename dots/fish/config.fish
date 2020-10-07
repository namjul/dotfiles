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
  set parts env functions path alias
  for part in $parts
    set file $HOME/.dotfiles/shell/$part.fish
    if test -e $file
      source $file
    end
  end

  # Theme
  theme_gruvbox 'dark' 'soft'
  set -g fish_color_command "#ebdbb2" # the color for commands

  # Tmux
  if command -v tmux > /dev/null 2>&1
     test -z $TMUX && tmux;
  end

  starship init fish | source
end
