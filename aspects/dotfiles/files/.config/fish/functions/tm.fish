function tm --description 'Create or switch tmux session via fzf'
  set -l change attach-session
  if test -n "$TMUX"
    set change switch-client
  end

  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux $change -t "$result"
end
