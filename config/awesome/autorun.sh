#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

function fin {
  if ! pgrep $1 ;
  then
    exec $@&
  fi
}

run setxkbmap -layout "de"
#run urxvtd -q -f -o
run udiskie
run redshift
run conky
compton -b --glx-no-stencil --xrender-sync-fence --vsync --shadow-exclude 'focused || !focused' #to lazy to write a config
run blueman-applet
run indicator-kdeconnect
fin nm-applet
