#
# ~/.bash_profile
#

## Set Environment Variables
# -----------------------------------------------------------------------------

export EDITOR=nvim

# bash history stuff
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%d/%m/%y %T"
export HISTCONTROL=ignoreboth:erasedups

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

# get qt5 apps to use native gtk style (through qt5-styleplugins)
export QT_QPA_PLATFORMTHEME=gtk2
export DESKTOP_SESSION=gnome

# change weechat home directory
export WEECHAT_HOME="$HOME/.config/weechat"

# always use ripgrep with fzf
export FZF_DEFAULT_COMMAND="rg --files --hidden --smart-case \
  --glob '!.git/*' --glob '!node_modules/*' 2> /dev/null"
# also use custom color configuration and keybindings
export FZF_DEFAULT_OPTS="--color 16,fg:15,bg:0,hl:11,fg+:15,bg+:237,hl+:11 \
  --color info:12,prompt:248,spinner:11,pointer:12,marker:208,header:241 \
  --color border:7 \
  --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"

# source sensitive environment variables which don't belong in a public repo
if [[ -r ~/.bash_profile.local ]]; then
  source ~/.bash_profile.local
fi

## Start session
# -----------------------------------------------------------------------------

if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  exec startx
elif [[ -r ~/.bashrc ]]; then
  source ~/.bashrc
fi
