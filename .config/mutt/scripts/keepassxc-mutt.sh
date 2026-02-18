#!/bin/bash
# shellcheck disable=SC2086,SC2155

###############################################################################
#        Read keepassxc email attributes into a format mutt can source        #
###############################################################################

database=${KEEPASSXC_DATABASE:-~/database.kdbx}
keyfile=${KEEPASSXC_KEYFILE:-} # optional
timeout=600

function get_secrets(){
  local entry secrets passwd="$(keyctl print "%user:$0" 2>/dev/null)" IFS=$'\n'

  for entry in "$@"; do
    coproc keepassxc-cli show -a UserName -a Email -a Password -k "$keyfile" \
      ${passwd:+--quiet} "$database" "$entry"

    if [[ -z "$passwd" ]]; then
      read -rs passwd
    fi

    exec 3>&"${COPROC[0]}"
    echo "$passwd">&"${COPROC[1]}"
    wait $COPROC_PID
    read -rd '' -u 3 -a secrets

    # if we misspelled the password, try again
    if [[ "${#secrets[@]}" -eq 0 ]]; then
      get_secrets "$@"
      return
    fi

    echo "set my_${entry@L}_user=${secrets[0]@Q}"
    echo "set my_${entry@L}_mail=${secrets[1]@Q}"
    echo "set my_${entry@L}_pass=${secrets[2]@Q}"
  done

  keyctl add user "$0" "$passwd" @u >/dev/null
  keyctl timeout "%user:$0" "$timeout"
}


if [[ -n "$*" ]]; then
  # also exit mutt when receiving interrupt from keyboard
  trap 'kill %% $PPID && exit' INT
  get_secrets "$@"
fi
