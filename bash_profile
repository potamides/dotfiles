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

# run askpass to enter password when not launched from a terminal
export SUDO_ASKPASS=/usr/lib/git-core/git-gui--askpass
export SSH_ASKPASS=$SUDO_ASKPASS

# local virtualenv with pipenv
export PIPENV_VENV_IN_PROJECT=1

# disable automated lockfile generation / update
export PIPENV_SKIP_LOCK=1

# to execute local executables
export PATH="${PATH}:${HOME}/.local/bin"

# find local executables installed by luarocks
export PATH="${PATH}:${HOME}/.luarocks/bin"

# get qt5 apps to use native gtk style (through qt5ct & qt5-styleplugins)
export QT_QPA_PLATFORMTHEME=qt5ct

# always use ripgrep with fzf
export FZF_DEFAULT_COMMAND="rg --files --hidden --smart-case \
  --glob '!.git/*' --glob '!node_modules/*' 2> /dev/null"
# also use gruvbox colors
export FZF_DEFAULT_OPTS='
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
'

## Start session
# -----------------------------------------------------------------------------

if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
elif [[ -r ~/.bashrc ]]; then
  source ~/.bashrc
fi
