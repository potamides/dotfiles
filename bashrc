#
# ~/.bashrc
#

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
  return
fi

# if not in vim or ranger show greeter
if [[ -z $VIMRUNTIME ]] && [[ -z $RANGER_LEVEL ]]; then
    neofetch
fi

# build prompt
# -----------------------------------------------------------------------------

# echo return code on failure
function __rc(){
   local exit=$?
   if [ $exit -ne 0 ]; then
     echo "$exit "
   fi
}

# sync terminal session command history
export PROMPT_COMMAND="history -a; history -c; history -r;"

# prompt stuff that should come before and after git integration
__pre='\[\e[01;91m\]$(__rc)\[\e[01;94m\]\u\[\e[m\]@\h \w'
__post="\n\$ "

# integrate git into prompt with PROMPT_COMMAND
if [[ -f /usr/share/git/git-prompt.sh ]]; then
  source /usr/share/git/git-prompt.sh
  export GIT_PS1_SHOWCOLORHINTS=1
  export PROMPT_COMMAND+="__git_ps1 ${__pre@Q} ${__post@Q}"
else
  # if the file doesn't exist create prompt directly with PS1
  export PS1="$__pre$__post"
fi


# shell behavior & keybindings
# -----------------------------------------------------------------------------

shopt -s histappend                 # Appends hist on exit
shopt -s cmdhist                    # Save multi-line hist as one line
shopt -s checkwinsize               # Update col/lines after commands
shopt -s checkjobs                  # deferr exit if jobs are running
shopt -s autocd                     # Can change dir without `cd`
shopt -s cdspell                    # Fixes minor spelling errors in cd paths
shopt -s no_empty_cmd_completion    # Stops empty line tab comp
shopt -s dirspell                   # Tab comp can fix dir name typos
shopt -s histappend                 # append to history, don't overwrite it

# readline stuff that actually should go into .inputrc
bind 'set show-all-if-ambiguous on'        # listing of multiple completions
bind 'set menu-complete-display-prefix on' # insert the common prefix
bind 'TAB: menu-complete'                  # steps through list of completions
bind '"\e[Z": menu-complete-backward'      # Shift-Tab: step in other direction
bind 'set colored-completion-prefix on'    # highlight the common prefix
bind 'set colored-stats on'                # color completions like "ls"
bind ' set mark-symlinked-directories 0n'  # Mark symlinked directories
bind 'set match-hidden-files off'          # don't match files starting with .
bind '"\e[A": history-search-backward'     # Up: search hist starting with line
bind '"\e[B": history-search-forward'      # Down: similar but other direction
#bind 'set editing-mode vi'                 # use vi keybindings
#bind 'set keyseq-timeout 50'               # reduce input delay on e.g. Escape
#bind 'set show-mode-in-prompt on'          # show editing mode in prompt

## Bash-completions
# -----------------------------------------------------------------------------

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# FZF config
# -----------------------------------------------------------------------------

if [[ -f /usr/share/fzf/key-bindings.bash && \
      -f /usr/share/fzf/completion.bash ]]; then
  source /usr/share/fzf/key-bindings.bash
  source /usr/share/fzf/completion.bash

  # Use rg instead of the default find command for listing path candidates.
  _fzf_compgen_path() {
    rg --files --hidden --smart-case --glob '!.git/*' --glob \
      '!node_modules/*' 2> /dev/null
  }

  # Use rg to generate the list for directory completion
  _fzf_compgen_dir() {
    rg --files --hidden --smart-case --glob '!.git/*'--glob \
      '!node_modules/*' --null 2> /dev/null | xargs -0 dirname | awk '!h[$0]++'
  }

  # Use highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
  export FZF_COMPLETION_OPTS="--preview '(highlight -O ansi -l {} \
    2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
  export FZF_DEFAULT_COMMAND="rg --files --hidden --smart-case \
    --glob '!.git/*' --glob '!node_modules/*' 2> /dev/null"

  # To apply the command to CTRL-T as well
  export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Preview directories with tree
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  export FZF_ALT_C_COMMAND=_fzf_compgen_dir
fi

## Functions
# -----------------------------------------------------------------------------

# colored manpages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# cd to directory and list files
function cl() {
    cd "$1" && ls -a
}

# search for patterns with ripgrep and open results in the editor
function rg_and_open(){
    FILES=$(rg -l "$@")
    if [[ ${#FILES} -gt 0 ]]; then
        echo $FILES | xargs -d "\n" $EDITOR
    else
        return 1
    fi
}

# report disk  usage, if file is a folder, sort files by size
function disk_usage_sorted(){
    local path
    if [[ -n $1 ]]; then
      path=$1/
    fi
    du -shc "$path".[^.]* "$path"* | sort -h
}

# search for keyword in pdf's in directory
function search_pdf(){
    local dir file
    if [[ -n $2 ]]; then
      dir=$2/
    fi
    for file in "$dir"*.pdf; do
      pdftotext "$file" - | grep "$1" >> /dev/null && echo "$file"
    done
}

# tldr version of man pages
function tldr(){
    curl cheat.sh/$*
}

# list package which owns command
function whoowns(){
  pacman -Qo "$@" || { echo "Provided by:" && pacman -F "$@"; }
}

# Aliases
# -----------------------------------------------------------------------------

# bring color to the terminal
alias ls='ls --color=auto -v'
alias la='ls --color=auto -vla'
alias ll='ls --color=auto -vl'
alias lh='ls --color=auto -vhAl'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

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
alias rgo=rg_and_open
alias calc='ipython --profile=calculate'
alias dus=disk_usage_sorted
alias spdf=search_pdf
alias htop='htop -t'
