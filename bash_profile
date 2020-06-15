#
# ~/.bash_profile
#

## Set Environment Variables
# -----------------------------------------------------------------------------

# bash history stuff
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%d/%m/%y %T"
export HISTCONTROL=ignoreboth:erasedups

export EDITOR=nvim

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

## Start session
# -----------------------------------------------------------------------------

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
elif [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi
