function fish_user_key_bindings
  # vi mode
  fish_vi_key_bindings
  bind -M insert -m default jk force-repaint

  # fzf
  bind \cf 'fzf-file-widget'
  bind \cr 'fzf-history-widget'
  bind \ec 'fzf-cd-widget'
  bind \ce 'fdo'
  bind --mode insert \cf 'fzf-file-widget'
  bind --mode insert \cr 'fzf-history-widget'
  bind --mode insert \ec 'fzf-cd-widget'
  bind --mode insert \ce 'fdo'

  # lf file manager
  bind \co 'set old_tty (stty -g); stty sane; lfcd; stty $old_tty; commandline -f repaint'
  bind --mode insert \co 'set old_tty (stty -g); stty sane; lfcd; stty $old_tty; commandline -f repaint'

end

fzf_key_bindings
