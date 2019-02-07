#!/bin/bash

config="${HOME}/.config/awesome/tmux.conf"
tmux -f $config new-session 'while true; do clear; ncmpcpp -s playlist_editor; sleep 0.1; done' \; \
split-window -h 'while true; do clear; ncmpcpp -s playlist; sleep 0.1; done' \; \
select-pane -t 1 \; \
split-window -v 'while true; do clear; ncmpcpp -s visualizer; sleep 0.1; done' \; \
select-pane -L \;
