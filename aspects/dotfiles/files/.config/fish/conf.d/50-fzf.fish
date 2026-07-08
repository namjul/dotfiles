export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs 2> /dev/null'
export FZF_DEFAULT_OPTS='--cycle --layout=reverse --border --height 75% --preview-window=wrap'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --null | xargs -0 dirname | sort | uniq"

if status is-interactive; and not set --query fzf_fish_custom_keybindings
  set --universal fzf_fish_custom_keybindings
end
