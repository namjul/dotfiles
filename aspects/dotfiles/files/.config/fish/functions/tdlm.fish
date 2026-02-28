# Create multiple tdl windows with one per subdirectory in the current directory
# Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]
function tdlm
  if test -z "$argv[1]"
    echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"
    return 1
  end

  if test -z "$TMUX"
    echo "You must start tmux to use tdlm."
    return 1
  end

  set -l ai "$argv[1]"
  set -l ai2 "$argv[2]"
  set -l base_dir "$PWD"
  set -l first true

  # Rename the session to the current directory name (replace dots/colons which tmux disallows)
  tmux rename-session (basename "$base_dir" | tr '.:' '--')

  for dir in "$base_dir"/*/
    if not test -d "$dir"
      continue
    end

    set -l dirpath (string trim -r -c / "$dir")

    if test "$first" = true
      # Reuse the current window for the first project
      tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
      set first false
    else
      set -l pane_id (tmux new-window -c "$dirpath" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
    end
  end
end
