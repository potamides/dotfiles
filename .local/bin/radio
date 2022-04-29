#!/bin/bash

###############################################################################
#              Interactively select a radio station to listen to.             #
###############################################################################

declare -x IFS=$'\n'
declare -A stations=(
  [CEU Medieval Radio]=http://stream3.virtualisan.net:7020
  [Chilled Cow]=https://youtu.be/5qap5aO4i9A
  [Code Radio]=https://coderadio-admin.freecodecamp.org/radio/8010/radio.mp3
  [FUTURE FNK]=http://node-16.zeno.fm:80/etbbu6a3dnruv
  [Gensokyo Radio]=https://stream.gensokyoradio.net/1
  [Hand of Doom Radio]=http://s5.nexuscast.com:8042/stream
  [Kohina]=http://kohina.duckdns.org:8000/stream.ogg
  [Nightride FM]=https://stream.nightride.fm/nightride.ogg
  [Nightwave Plaza]=https://radio.plaza.one/mp3
  [No-Life Radio]=http://listen.nolife-radio.com:8000
  [Radio Monacensis]=https://monacensis.stream.laut.fm/monacensis
  [Shonan Beach FM]=http://shonanbeachfm.out.airtime.pro:8000/shonanbeachfm_c
)

select station in $(sort <<< "${!stations[@]}"); do
  if [[ -n "$station" ]]; then
    exec mpv --no-video "${stations[$station]}"
  fi
done
