# shellcheck shell=bash disable=SC1090

## Set Environment Variables
# -----------------------------------------------------------------------------

export BROWSER="qutebrowser"
export {EDITOR,VISUAL}="nvim"
export TERMCMD="alacritty msg create-window"

# merge program for pacdiff
export DIFFPROG="$EDITOR -d"

# find locally installed executables
export PATH="$HOME/.local/bin:$HOME/.luarocks/bin:$PATH"

# run askpass to enter password when not launched from a terminal
export SUDO_ASKPASS="/usr/lib/git-core/git-gui--askpass"
export SSH_ASKPASS="$SUDO_ASKPASS"

# configure qt apps for wayland and native gtk style (through qt5-styleplugins)
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME="gtk2"
export DESKTOP_SESSION="gnome"

# integrate Fcitx input method framework
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XMODIFIERS="@im=fcitx"

# set path to configuration files for some programs
export WEECHAT_HOME="$HOME/.config/weechat"
export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc"
export PYTHONSTARTUP="$HOME/.config/python/config.py"
export INPUTRC="$HOME/.config/readline/inputrc"

# custom fzf color configuration and keybindings
export FZF_DEFAULT_OPTS="--color 16,fg:15,bg:0,hl:11,fg+:15,bg+:237,hl+:11 \
  --color info:12,prompt:248,spinner:11,pointer:12,marker:208,header:241 \
  --color border:7 --bind alt-a:toggle-all \
  --walker-skip .git,node_modules,.venv"

# set up LS_COLORS environment variable
eval "$(dircolors)"

# colored manpages
export MANPAGER="less -Dd+R -DuGd -Dsybd"
export MANROFFOPT='-c'

# use old python repl which supports vi mode
export PYTHON_BASIC_REPL="true"

# source environment variables which are not under version control
if [[ -r ~/.bash_profile.local ]]; then
  source ~/.bash_profile.local
fi

## Start session
# -----------------------------------------------------------------------------

if [[ -z $DISPLAY && -n $(type -p somewm) && $(tty) = /dev/tty1 ]]; then
  for card in /sys/class/drm/card?; do
    if [[ -e $card/device/removable ]]; then
      egpu=/dev/dri/${card##*/}
    else
      rest="$rest${rest:+:}/dev/dri/${card##*/}"
    fi
  done
  if [[ -v egpu ]]; then
    # prompt if eGPU should be used as video device when available
    read -rp "Force eGPU as primary card? [y/N] " -st 3 -n 1 reply
    if [[ $reply = [yY]* ]]; then
      export WLR_DRM_DEVICES="$egpu${rest:+:$rest}"
    fi
  fi
  exec somewm-session
elif [[ -r ~/.bashrc ]]; then
  source ~/.bashrc
fi
