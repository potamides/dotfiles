#!/bin/bash
# shellcheck disable=SC2128,SC2206

###############################################################################
#    Timer for steeping tea. Expects steeping time in minutes as arguments.   #
#             Sends a desktop notification when the tea is ready.             #
###############################################################################

shopt -s nullglob

iconpath="/usr/share/icons/*/32x32/*"
icon=(
  # stuff that looks like tea, first match is used
  $iconpath/kteatime.svg
  $iconpath/java.svg
)

(
  sleep $((${1:?"Expected steeping time as argument!"} * 60))
  notify-send --icon="$icon" --urgency=normal --expire-time=0 "Tea is ready!" \
    "Now savour your cup of brown joy."
)&
