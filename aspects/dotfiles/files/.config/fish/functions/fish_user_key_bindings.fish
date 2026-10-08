
# fish automatically executes a function called `fish_user_key_bindings` if it exists.

fzf_key_bindings

function fish_user_key_bindings

  # vi mode
  if test -z "$NVIM"
    fish_vi_key_bindings
    bind -M insert -m default jk force-repaint
  end

  # fzf
  bind \cf 'fzf-file-widget'
  bind \cr 'fzf-history-widget'
  bind \ec 'fzf_change_directory'
  bind \co 'fdo'
  bind --mode insert \cf 'fzf-file-widget'
  bind --mode insert \cr 'fzf-history-widget'
  bind --mode insert \ec 'fzf_change_directory'
  bind --mode insert \co 'fdo'

  # terminal file manager (yazicd restores TTY after yazi)
  bind \eo 'yazicd; commandline -f repaint'
  bind --mode insert \eo 'yazicd; commandline -f repaint'

  # howto: suggest command on the line (no TIOCSTI; see bin/howto-suggest)
  bind \cg howto_fill
  bind --mode insert \cg howto_fill

end
