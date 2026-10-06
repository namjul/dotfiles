function commit --description "Create a commit using the pi /commit prompt"
  is_in_git_repo || return
  pi -p -a --no-session --model openrouter/free "/commit" $args
end
