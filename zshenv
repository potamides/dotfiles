#!/usr/bin/zsh

export EDITOR="nvim"

# local virtualenv with pipenv
export PIPENV_VENV_IN_PROJECT=1

# disable automated lockfile generation / update
export PIPENV_SKIP_LOCK=1

# to execute local executables
export PATH="${PATH}:${HOME}/.local/bin"

export LIBVA_DRIVER_NAME=radeonsi

#function check_battery_preexec(){
#if [[ -z $(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "state:               discharging") ]]
#    then
#        export DRI_PRIME=1
#    else
#        export DRI_PRIME=0
#fi
#}
#autoload -U add-zsh-hook
#add-zsh-hook -Uz preexec check_battery_preexec
#check_battery_preexec
