#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#run urxvtd -q -f -o
run udiskie
run redshift
run conky
#compton -b --backend glx --glx-no-stencil --xrender-sync-fence --glx-no-rebind-pixmap --shadow-exclude 'focused || !focused' #to lazy to write a config
#run blueman-applet
#run indicator-kdeconnect
#run nm-applet
