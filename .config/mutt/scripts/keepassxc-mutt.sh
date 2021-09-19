#!/bin/bash
# shellcheck disable=SC2086

###############################################################################
#        Read keepassxc email attributes into a format mutt can source        #
###############################################################################

database=${KEEPASSXC_DATABASE:-~/database.kdbx}
keyfile=${KEEPASSXC_KEYFILE:-} # optional

function get_secrets(){
  local entry password secrets quiet IFS=$'\n'

  for entry in "$@"; do
    coproc keepassxc-cli show -a UserName -a Email -a Password -k "$keyfile" \
      $quiet "$database" "$entry"

    if [[ -z "$password" ]]; then
      read -rs password
    fi
    exec 3>&"${COPROC[0]}"
    echo "$password">&"${COPROC[1]}"
    wait $COPROC_PID
    read -rd '' -u 3 -a secrets

    # if we misspelled the password, try again
    if [[ "${#secrets[@]}" -eq 0 ]]; then
      get_secrets "$@"
      return
    fi

    quiet="--quiet" # don't show keepassxc prompt on subsequent entries
    echo "set my_${entry@L}_user=${secrets[0]@Q}"
    echo "set my_${entry@L}_mail=${secrets[1]@Q}"
    echo "set my_${entry@L}_pass=${secrets[2]@Q}"
  done
}


if [[ -n "$*" ]]; then
  # also exit mutt when receiving interrupt from keyboard
  trap 'kill $PPID && exit' INT
  get_secrets "$@"
fi
