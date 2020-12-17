function fish_user_key_bindings
  # vi mode
  fish_vi_key_bindings
  bind -M insert -m default jk force-repaint
  bind -M insert -m default \ck force-repaint

  # fzf
  bind \cf '__fzf_search_current_dir'
  bind \cr '__fzf_search_history'
  bind \cv '__fzf_search_shell_variables'
  bind --mode insert \cf '__fzf_search_current_dir'
  bind --mode insert \cr '__fzf_search_history'
  bind --mode insert \cv '__fzf_search_shell_variables'

  ## git
  bind \cg\cl '__fzf_search_git_log'
  bind \cg\cf '__fzf_search_git_status'
  bind --mode insert \cg\cl '__fzf_search_git_log'
  bind --mode insert \cg\cf '__fzf_search_git_status'

end

fzf_key_bindings
