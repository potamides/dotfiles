#!/bin/bash
secondaryOutput=$(xrandr | grep " connected" | grep -v primary | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
primaryOutput=$(xrandr | grep -E " connected primary" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
disconnectedOutputs=$(xrandr | grep " disconnected" | sed -e "s/\([A-Z0-9]\+\) disconnected.*/\1/")


if [[ -z $secondaryOutput ]]; then
    for display in $disconnectedOutputs; do
        xrandr --output $display --off
    done
else
    xrandr --output $secondaryOutput --above $primaryOutput --auto
fi



