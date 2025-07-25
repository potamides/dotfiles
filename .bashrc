# shellcheck shell=bash disable=SC1091,SC2016,SC2028,SC2034,SC2059,SC2139

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
  return
fi

## show greeter
# -----------------------------------------------------------------------------

# if not in vim or ranger show reminders for today
if [[ -z $NVIM && -z $RANGER_LEVEL && -n $(type -t when) ]]; then
  when --wrap=78 --noheader --styled_output_if_not_tty w | sed 's/^/│ /' |
    xargs -r0 printf "┌─[ Reminders ]\\n%s└$(printf '%0.s─' {0..22})\\n"
fi

## build prompt
# -----------------------------------------------------------------------------

function __start_ps1(){
  local fmt args time=$((SECONDS-START_TIME)) exit_code=$?
  local white='\[\e[37m\]' ylw='\[\e[33m\]' reset='\[\e[m\]'
  local boldred='\[\e[1;31m\]' boldblue='\[\e[1;34m\]'

  if [[ -v REPORT_STATUS && $exit_code -ne 0 ]]; then
    # display exit code of previous command if it is nonzero
    __printf "%s " "$boldred$exit_code"
  fi

  if [[ $EUID -eq 0 ]]; then
    __printf "%s" "$boldred\u$reset"
  else
    __printf "%s" "$boldblue\u$reset"
  fi

  __printf "@%s %s" "\h" "$white\w$reset"

  if [[ -v REPORT_STATUS ]]; then
    local -x TZ=UTC0 # interpret $time as unix epoch time
    # ring bell and show execution time of previous command if above threshold
    if ((time >= 10)); then
      __printf "\[\a\]"
      if ((time >= 86400)); then
        __printf " (%s%d-%(%T)T%s)" "$ylw" "$((time/86400))" "$time" "$reset"
      elif ((time >= 3600)); then
        __printf " (%s%(%-H:%M:%S)T%s)" "$ylw" "$time" "$reset"
      else
        __printf " (%s%(%-M:%S)T%s)" "$ylw" "$time" "$reset"
      fi
    fi
  fi

  printf -v START_PS1 "$fmt" "${args[@]}"
}

function __end_ps1(){
  local fmt args purple='\[\e[35m\]' aqua='\[\e[36m\]' reset='\[\e[m\]'

  if [[ -n "$VIRTUAL_ENV" ]]; then
    __printf " (%s)" "$purple${VIRTUAL_ENV##*/}$reset"
  fi

  # output of $(jobs) is updated only after evaluating PROMPT_COMMAND, so we
  # have to check ourselves which jobs are still alive here
  for pid in ${ jobs -p; }; do
    if kill -0 "$pid" &> /dev/null; then
      local -i alive+=1
    fi
  done

  if [[ -v alive ]]; then
    __printf " (%s%d job%.*s%s)" "${aqua}" "$alive" $((alive>1)) s "${reset}"
  fi

  printf -v END_PS1 "$fmt%s>%s " "${args[@]}" "\n" "$reset"
}

function __printf(){
  fmt+="$1" args+=("${@:2}")
}

# integrate git into prompt via PROMPT_COMMAND
if [[ -r /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh
  GIT_PS1_SHOWCOLORHINTS=yes GIT_PS1_SHOWCONFLICTSTATE=yes
  PROMPT_COMMAND=(__start_ps1 __end_ps1 '__git_ps1 "$START_PS1" "$END_PS1"')
else
  PROMPT_COMMAND=(__start_ps1 __end_ps1 'PS1="$START_PS1$END_PS1"')
fi

# whenever PS0 is evaluated (non-empty command) set status flag and timestamp
PS0='\[${PS0:$((START_TIME=$SECONDS, REPORT_STATUS=yes, 0)):0}\]'
PROMPT_COMMAND+=("unset START_TIME REPORT_STATUS START_PS1 END_PS1")

PROMPT_DIRTRIM=3
PS2="» "

## general shell behavior
# -----------------------------------------------------------------------------

shopt -s histappend                 # append history on exit, don't overwrite
shopt -s lithist                    # Save multi-line cmd with embedded newline
shopt -s checkwinsize               # Update col/lines after commands
shopt -s checkjobs                  # defer exit if jobs are running
shopt -s autocd                     # Can change dir without `cd`
shopt -s cdspell                    # Fixes minor spelling errors in cd paths
shopt -s no_empty_cmd_completion    # Stops empty line tab comp
shopt -s dirspell                   # Tab comp can fix dir name typos
shopt -s globstar                   # pattern ** also searches subdirectories
shopt -s extglob                    # enable extended pattern matching features

# reset cursor shape before executing a command (see .config/readline/inputrc)
if [[ $TERM = linux ]]; then
  PS0+='\[\e[?8c\]'
else
  PS0+='\[\e[2 q\]'
fi

# bash history stuff
HISTSIZE=10000
HISTFILESIZE=inf
HISTTIMEFORMAT="%d/%m/%y %T "
HISTCONTROL=ignoreboth:erasedups
# don't append wifi passwords to history file
HISTIGNORE="nmcli d* w* [ch]* * password *"
PROMPT_COMMAND+=("history -a")

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
alias pac='pacman'
alias spac='sudo pacman'
alias apac='yay -a --editmenu'
alias pacli='pacman -Q | wc -l'
alias pacro='pacman -Qtd > /dev/null && sudo pacman -Rns $(pacman -Qtdq)'
alias calc='ptpython -i <(echo "from math import *; from statistics import *")'
alias todo='$EDITOR +sil\ /^##\ $(date +%A) +noh +norm\ zz ~/Documents/TODO.md'
alias {vim,nvim}="$EDITOR"
alias bell="printf '\a'"
alias nmcli='nmcli --ask --pretty'
alias server='python3 -m http.server 9999'
alias {dotfiles,dofi}='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias rec='ffmpeg -f x11grab -i $DISPLAY -f pulse -i default -y'
alias backup="sudo snap-sync --config home --noconfirm --UUID \
  \"\$(lsblk -no UUID /dev/disk/by-label/backup)\""

# fun stuff
alias starwars='telnet towel.blinkenlights.nl'
alias maps='telnet mapscii.me'
alias 2048='ssh play@ascii.town'
alias tron='ssh sshtron.zachlatta.com'
alias nyancat="mpv --no-terminal --no-video --loop ytdl://QH2-TGUlwu4 & \
  telnet rainbowcat.acc.umu.se; kill %%"

## Bash-completions
# -----------------------------------------------------------------------------

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# sourcing order is important, see
# https://github.com/cykerway/complete-alias/issues/46
if [[ -n $(type -t fzf) ]]; then
  eval "$(fzf --bash)"
fi

# external alias completion, progcomp_alias shopt builtin sadly doesn't work
# https://github.com/scop/bash-completion/issues/383
if [[ -r /usr/share/bash-complete-alias/complete_alias ]]; then
  COMPAL_AUTO_UNMASK=1
  source /usr/share/bash-complete-alias/complete_alias
  complete -F _complete_alias "${!BASH_ALIASES[@]}"
fi

## FZF config for interactive use
# -----------------------------------------------------------------------------

if [[ -n $(type -t fzf) ]]; then
  # syntax highlight matches and preview directories
  FZF_COMPLETION_OPTS="--preview '{ pygmentize -f terminal {} || cat {} ||
    tree -C {}; } 2> /dev/null | head -200'"
  # To apply the command to CTRL-T as well
  FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
  # Preview directories with tree
  FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  # preview long commands with "?"
  FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap \
    --bind '?:toggle-preview'"

  # https://github.com/junegunn/fzf/blob/master/ADVANCED.md#ripgrep-integration
  function lgrep(){
    rm -f /tmp/rg-fzf-{r,f}
    local rg_prefix="rg --column --line-number --no-heading --color=always"
    rg_prefix+=" --smart-case --hidden --glob '!{.git,node_modules,.venv}'"
    local switch='%s(change)+change-prompt(%s> )+%s+transform-query:"'
    switch+='echo \{q} > /tmp/rg-fzf-%s; cat /tmp/rg-fzf-%s\n'

    fzf --ansi --multi --disabled --query "${*:-}" \
      --bind "start:reload:$rg_prefix {q} || true" \
      --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
      --bind "ctrl-g:transform:[[ ! \$FZF_PROMPT =~ regex ]] &&
        printf ${switch@Q} rebind regex disable-search f r ||
        printf ${switch@Q} unbind fuzzy enable-search r f" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt 'regex> ' \
      --delimiter : \
      --header 'ctrl-g to switch between fuzzy/regex search' \
      --preview "pygmentize -f terminal {1} || cat {1}" \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind "enter:become($EDITOR +{2} {1})"
  }
fi

## Functions
# -----------------------------------------------------------------------------

# colored manpages
function man(){
  GROFF_NO_SGR=1 \
  LESS_TERMCAP_md=$'\e[01;31m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[01;44;33m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[01;32m' \
  command man "$@"
}

# report disk usage of directory and sort files by size
function dusort(){
  find "$@" -mindepth 1 -maxdepth 1 -exec du -sch {} + | sort -h
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
  pacman -Qlq "$@" | grep -F "${PATH//:/$'\n'}" | sed -rn 's|.*/([^/]+)$|\1|p'
}

# find fonts which contain character(s)
function findfonts(){
  fc-list ":charset=$(printf "%x " "${@/#/\'}")" family style
}

# fetch current weather report, with location as optional parameter
function weather(){
  local request="wttr.in/${*^}?Fm"
  if [[ "$(tput cols)" -lt 125 ]]; then
    request+='n'
  fi
  curl -H "Accept-Language: ${LANG%_*}" --compressed "${request// /+}"
}

# Conveniently copy files to NAS
function ncp(){
  rsync --info=progress2 --recursive --protect-args --times --perms \
    --chmod=D775,F664 "${1%/}" "${2:+NAS:/media/storage/$2}"
}

## window title and current working directory
# -----------------------------------------------------------------------------

# advise the terminal of the current working directory
PROMPT_COMMAND+=('printf "\e]7;file://%s%s\e\\" "$HOSTNAME" "$PWD"')

# set window title to currently running command or current working directory
PROMPT_COMMAND+=('[ -n "$BASH_COMMAND" ] && printf "\e]0;%s\a" "$PWD"')
trap 'printf "\e]0;%s\a" "${BASH_COMMAND//[^[:print:]]/}"' DEBUG
