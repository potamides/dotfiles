#!/bin/bash

###############################################################################
#        Read keepassxc email attributes into a format mutt can source        #
###############################################################################

database=${KEEPASSXC_DATABASE:-~/Passwords.kdbx}
keyfile=${KEEPASSXC_KEYFILE:-~/Secret.key}

function get_secrets(){
  local secrets IFS=$'\n'
  # shellcheck disable=SC2207
  secrets=($(keepassxc-cli show --attributes UserName --attributes Email \
    --attributes Password --key-file "$keyfile" "$database" "$1"))

  # if we misspelled the password, try again
  if [[ $? -ne 0 ]]; then
    get_secrets "$1"
    return
  fi
  
  echo set my_user="${secrets[0]@Q}"
  echo set my_mail="${secrets[1]@Q}"
  echo set my_pass="${secrets[2]@Q}"
}

if [[ -n $1 ]]; then
  get_secrets "$1"
fi
