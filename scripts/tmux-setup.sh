#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied, requires name of window."
    exit 1
fi

CWD=$(pwd)
SESSION_NAME=${1:-dev}


tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ] ; then
  set -- $(stty size) # $1 = rows $2 = columns
  tmux new-session -d -s "$SESSION_NAME" -x "$2" -y "$(($1 - 1))" -n 'code' 
  tmux new-window -t "$SESSION_NAME" -n 'bash'
  tmux new-window -t "$SESSION_NAME" -n 'notes'
  tmux new-window -t "$SESSION_NAME" -n 'dotfiles'

  tmux select-window -t "$SESSION_NAME:4"
  tmux send-keys "cdd" Enter
  tmux send-keys "clear" Enter

  tmux select-window -t "$SESSION_NAME:3"
  tmux send-keys "dnote view" Enter

  tmux select-window -t "$SESSION_NAME:2"
  tmux split-window -h

  tmux select-window -t "$SESSION_NAME:1"
  tmux send-keys "nvim" Enter
fi

# detach from a tmux session if in one
tmux detach > /dev/null

tmux attach -t "$SESSION_NAME"
