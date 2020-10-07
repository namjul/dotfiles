#
#  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗    ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝    ██╔════╝██║██╔════╝██║  ██║
# ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗   █████╗  ██║███████╗███████║
# ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║   ██╔══╝  ██║╚════██║██╔══██║
# ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝██╗██║     ██║███████║██║  ██║
#  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
#


# check if brew command exists
if ! type -q brew
  echo "Make sure `brew` command is available."
  exit
end

if status is-login
  # Initialize Homebrew
  # test -e ~/.linuxbrew && eval (~/.linuxbrew/bin/brew shellenv)
  # test -e /home/linuxbrew/.linuxbrew/bin/brew && eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

  # Initialize asdf
  # source (brew --prefix asdf)/asdf.fish

  # Local settings
  # test -e $HOME/.localrc && source $HOME/.localrc
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

  # if test -e ~/.localrc
  #   source ~/.localrc
  # end

  # Theme
  theme_gruvbox 'dark' 'soft'
  set -g fish_color_command "#ebdbb2" # the color for commands


  # Tmux
  if command -v tmux > /dev/null 2>&1
     # test -z $TMUX && tmux;
  end

  starship init fish | source
end
