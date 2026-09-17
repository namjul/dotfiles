#!/usr/bin/env bash

# send command to all nvim instances
# run `nvim-ctrl.sh 'set background=dark'`
# see: https://github.com/chmln/nvim-ctrl/issues/1

cmd=$1
pids=()

notify_server() {
  local server=$1
  # Probe: stale sockets can outlive a wedged nvim; skip RPC that never answers.
  timeout 0.2 nvim --server "$server" --remote-expr "1+1" >/dev/null 2>&1 || return 0
  # Command: only sent after a responsive server is confirmed.
  timeout 2 nvim --server "$server" --remote-expr "execute('$cmd')" >/dev/null 2>&1 || true
}

for server in "$XDG_RUNTIME_DIR"/nvim.*.0; do
  [[ -S "$server" ]] || continue
  notify_server "$server" &
  pids+=($!)
done

for pid in "${pids[@]}"; do
  wait "$pid" 2>/dev/null || true
done

