if status is-interactive
  set fish_greeting

  # Set Lenovo Trackpoint Speed
  if command -q xinput; and xinput list-props "TPPS/2 Synaptics TrackPoint" > /dev/null 2>&1
    # TODO check if still needed on arch
    xinput set-prop "TPPS/2 Synaptics TrackPoint" "libinput Accel Speed" -0.5
  end

  mise activate fish | source

  # if command -q starship; starship init fish | source; end
  if command -q zoxide; zoxide init fish | source; end
  if command -q direnv; direnv hook fish | source; end
  if command -q scmpuff; scmpuff init -s --shell=fish | source; end
  if command -q fnox; fnox activate fish | source; end

  # Tmux
  if command -v tmux > /dev/null 2>&1; and test "$TERM_PROGRAM" != ghostty
    set -gx SHELL (status fish-path)
    test -z $TMUX && tmux new-session
  end
end
