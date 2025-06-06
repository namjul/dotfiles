
# fish automatically executes a function called `fish_user_key_bindings` if it exists.

fzf_key_bindings

function fish_user_key_bindings
  # vi mode
  fish_vi_key_bindings
  bind -M insert -m default jk force-repaint

  # fzf
  bind \cf 'fzf-file-widget'
  bind \cr 'fzf-history-widget'
  bind \ec 'fzf_change_directory'
  bind \co 'fdo'
  bind --mode insert \cf 'fzf-file-widget'
  bind --mode insert \cr 'fzf-history-widget'
  bind --mode insert \ec 'fzf_change_directory'
  bind --mode insert \co 'fdo'

  # lf file manager
  bind \eo 'set old_tty (stty -g); stty sane; yazicd; stty $old_tty; commandline -f repaint'
  bind --mode insert \eo 'set old_tty (stty -g); stty sane; yazicd; stty $old_tty; commandline -f repaint'

end
