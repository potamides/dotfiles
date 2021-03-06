# shellcheck shell=bash

## show greeter
# -----------------------------------------------------------------------------

# if not in vim or ranger show reminders for today
if [[ -z $VIMRUNTIME && -z $RANGER_LEVEL && $(type -t when) ]]; then
  when --rows=10 --norows_auto --noheader --styled_output_if_not_tty w |
    sed 's/^/| /' | xargs -r -0 printf ',---- [ Reminders ]\n%s`---- '
fi

## build prompt
# -----------------------------------------------------------------------------

boldblue='\e[1;34m'
boldred='\e[1;31m'
reset='\e[m'
# echo return code on failure
returncode="\`exit=\$?; [ \$exit -ne 0 ] && echo \"$boldred\$exit \"\`"
# root user is red, other users are blue
user="\`[ \$EUID -eq 0 ] && echo \"$boldred\"\u || echo \"$boldblue\"\u\`"
dir="\[$reset\]@\h \w"

# prompt stuff that should come before and after git integration
firstline=$returncode$user$dir
secondline='\n\$ '

# integrate git into prompt with PROMPT_COMMAND
if [[ -r /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh
  GIT_PS1_SHOWCOLORHINTS=1
  PROMPT_COMMAND="__git_ps1 '$firstline' '$secondline';"
else
  # if the file doesn't exist create prompt directly with PS1
  PS1="$firstline$secondline"
fi

unset boldblue boldred reset returncode user dir firstline secondline

## general shell behavior
# -----------------------------------------------------------------------------

shopt -s histappend                 # append history on exit, don't overwrite
shopt -s lithist                    # Save multi-line cmd with embedded newline
shopt -s checkwinsize               # Update col/lines after commands
shopt -s checkjobs                  # deferr exit if jobs are running
shopt -s autocd                     # Can change dir without `cd`
shopt -s cdspell                    # Fixes minor spelling errors in cd paths
shopt -s no_empty_cmd_completion    # Stops empty line tab comp
shopt -s dirspell                   # Tab comp can fix dir name typos
shopt -s globstar                   # pattern ** also searches subdirectories
shopt -s extglob                    # enable extended pattern matching features
shopt -so vi                        # enable vi like keybindings

# reset cursor shape before executing a command (see .inputrc)
if [[ $TERM = linux ]]; then
  PS0="\e[?8c"
else
  PS0="\e[2 q"
fi

# bash history stuff
HISTSIZE=5000
HISTFILESIZE=50000
HISTTIMEFORMAT="%d/%m/%y %T "
HISTCONTROL=ignoreboth:erasedups
# don't append wifi passwords to history file
HISTIGNORE="nmcli d* w* [ch]* * password *"
PROMPT_COMMAND+="history -a;"

## FZF config for interactive use
# -----------------------------------------------------------------------------

if [[ -r /usr/share/fzf/key-bindings.bash && \
      -r /usr/share/fzf/completion.bash ]]; then
  source /usr/share/fzf/key-bindings.bash
  source /usr/share/fzf/completion.bash

  # Use rg instead of the default find command for listing path candidates.
  function _fzf_compgen_path(){
    rg --files --hidden --smart-case --glob '!.git/*' --glob \
      '!node_modules/*' 2> /dev/null "${1-.}"
  }

  # Use rg to generate the list for directory completion
  function _fzf_compgen_dir(){
    rg --files --hidden --smart-case --null --glob '!.git/*' --glob \
      '!node_modules/*' "${1-.}" 2> /dev/null \
      | xargs -0 dirname | awk '!h[$0]++'
  }

  # syntax highlight matches and preview directories
  FZF_COMPLETION_OPTS="--preview '(pygmentize -f terminal {} \
    2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

  # To apply the command to CTRL-T as well
  FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
  FZF_CTRL_T_COMMAND=_fzf_compgen_path

  # Preview directories with tree
  FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  FZF_ALT_C_COMMAND=_fzf_compgen_dir

  # preview long commands with "?"
  FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap \
    --bind '?:toggle-preview'"
fi

## Functions
# -----------------------------------------------------------------------------

# colored manpages
function man(){
  LESS_TERMCAP_md=$'\e[01;31m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[01;44;33m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[01;32m' \
  command man "$@"
}

# Searching file contents with fzf and ripgrep
function fif(){
  if [[ "$#" -eq 0 ]]; then
    echo "Need a string to search for!" >&2
    return 1
  fi
  rg --files-with-matches --no-messages "$@" \
    | fzf --multi --preview "pygmentize -f terminal {} 2> /dev/null \
    | rg --colors match:bg:yellow --ignore-case --pretty --context 10 '${!#}' \
    || rg --ignore-case --pretty --context 10 '${!#}' {}"
}

# Edit files found with fif with editor
function fifo(){
  fif "$@" | xargs -rd "\n" "$EDITOR"
}

# report disk usage of directory and sort files by size
function dusort(){
  find "$@" -mindepth 1 -maxdepth 1 -exec du -sch {} + | sort -h
}

# search for keyword in pdf's in current directory
function spdf(){
  if [[ "$#" -eq 0 ]]; then
    echo "Need a string to search for!" >&2
    return 1
  fi
  for file in *.pdf; do
    pdftotext -q "$file" - | grep "$@" --quiet && echo "$file"
  done
}

# tldr version of man pages
function tldr(){
  local IFS=-
  curl cheat.sh/"$*"
}

# list package which owns command
function whoowns(){
  pacman -Qo "$@" 2> /dev/null || pacman -F "$@"
}

# list commands which are provided by package
function listprogs(){
  pacman -Qlq "$@" | grep -Po "(?<=${PATH//://|}/).+"
}

# find fonts which contain character(s)
function findfonts(){
  fc-list ":charset=$(printf "%x " "${@/#/\'}")" family style
}

# fetch current weather report, with location as optional parameter
function weather(){
    local request="wttr.in/${*^}?F"
    if [[ "$(tput cols)" -lt 125 ]]; then
      request+='n'
    fi
    curl -H "Accept-Language: ${LANG%_*}" --compressed "$request"
}

# Conveniently copy files to NAS
function ncp(){
  rsync --info=progress2 --recursive --protect-args --times --perms \
    --chmod=D775,F664 "${1%/}" "${2:+NAS:/media/storage/$2}"
}

## Aliases
# -----------------------------------------------------------------------------

# bring color to the terminal
alias ls='ls --color=auto -v'
alias la='ls --color=auto -vla'
alias ll='ls --color=auto -vl'
alias lh='ls --color=auto -vhAl'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias info="info --vi-keys -v match-style=underline,bold,nocolor \
  -v link-style=yellow -v active-link-style=yellow,bold"

# other useful aliases
alias pac='sudo pacman -S' # install
alias paca='yay -Sa' # aur install
alias pacu='sudo pacman -Syu' # update
alias pacau='yay -Syua' # aur update
alias pacr='sudo pacman -Rsn' # remove
alias pacs='pacman -Ss' # search
alias pacas='yay -Ssa' # aur search
alias paci='pacman -Qi' # info
alias pacl='pacman -Ql' # list files
alias paclo='pacman -Qdt' # list orphans
alias pacro='paclo && sudo pacman -Rns $(pacman -Qtdq)' # remove orphans
alias pacc='sudo pacman -Scc' # clean cache
alias pacli='pacman -Q | wc -l' # list user installed packages
alias sh='sh +o history' # prevent sh from truncating HISTFILE
alias calc='ptpython -i <(echo "from math import *")'
alias htop='htop -t'
alias todo='$EDITOR ~/Documents/TODO.md'
alias serve='python3 -m http.server 9999'
alias debug='set -o verbose && set -o xtrace'
alias nodebug='set +o verbose && set +o xtrace'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias rec='ffmpeg -s 1920x1080 -f x11grab -i $DISPLAY.0+0,0 -f pulse -i 0 -y'
alias backup="sudo snap-sync --UUID 940761e2-7d84-4025-8972-89276e53bdc4 \
  --config home --noconfirm"

# fun stuff
alias starwars='telnet towel.blinkenlights.nl'
alias maps='telnet mapscii.me'
alias 2048='ssh play@ascii.town'
alias tron='ssh sshtron.zachlatta.com'
alias incognito='unset HISTFILE'
alias tmpv="mpv --no-config --really-quiet --vo=tct --keep-open=yes \
  --profile=sw-fast"

## Bash-completions
# -----------------------------------------------------------------------------

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# external alias completion, progcomp_alias shopt builtin sadly doesn't work
# https://github.com/scop/bash-completion/issues/383
if [[ -r /usr/share/bash-complete-alias/complete_alias ]]; then
  source /usr/share/bash-complete-alias/complete_alias
  complete -F _complete_alias la ll lh pac paca pacu pacau pacr pacs pacas \
    paci pacl paclo pacro pacc pacli calc dotfiles
fi

## stuff that should be executed last
# -----------------------------------------------------------------------------

# set window title to currently running command or running shell
PROMPT_COMMAND+='[ -n "$BASH_COMMAND" ] && printf "\e]0;%s\a" "$SHELL";'
trap 'printf "\e]0;%s\a" "${BASH_COMMAND//[^[:print:]]/}"' DEBUG
