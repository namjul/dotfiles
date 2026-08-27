function ff --wraps="fzf --preview 'bat --style=numbers --color=always {}'" --description "fzf with bat preview"
  fzf --preview 'bat --style=numbers --color=always {}' $argv
end
