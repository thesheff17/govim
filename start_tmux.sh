#!/bin/bash
SESSION="work"

# start new session
tmux -2 new-session -d -s $SESSION

# split window at bottom 20% good with macbook pro
tmux split-window -v -p 20
tmux send-keys "qq" C-m

# Setup a window for tailing log files
tmux new-window -t $SESSION:1 -n 'logs'

tmux select-window -t $SESSION:0
tmux select-pane -t 0

tmux -2 attach-session -t $SESSION
