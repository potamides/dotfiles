#!/usr/bin/zsh

export EDITOR="nvim"

# local virtualenv with pipenv
export PIPENV_VENV_IN_PROJECT=1

# disable automated lockfile generation / update
export PIPENV_SKIP_LOCK=1

# to execute local executables
export PATH="${PATH}:${HOME}/.local/bin"

# find local executables installed by luarocks
export PATH="${PATH}:${HOME}/.luarocks/bin"

# get qt5 apps to use native gtk style (with qt5ct)
export QT_QPA_PLATFORMTHEME=qt5ct

# Report execution time when a program takes longer than 60s
export REPORTTIME=60
