#!/bin/bash

###############################################################################
# Read email from stdin and identify sender address. Create an alias for that #
#    address in the format mutt expects. Then, if no alias for that address   #
#  exists yet, append it to the alias file. Also handles duplicate nicknames. #
#              Inspired by this: http://wcaleb.org/blog/mutt-tips             #
###############################################################################

shopt -s extglob
alias_file=~/.config/mutt/aliases

function create_alias(){
  local line words nickname count

  while read -ra line; do
    # find line with "From:" filed and check if it ends with an email
    if [[ ${line[0]} == From: && ${line[-1]} == *@*.* ]]; then
      # remove punctuation and email suffix
      words=("${line[@]//?(@*.*|[[:punct:]])}")

      case ${#line[@]} in
        1)   ;;
        2|3) nickname=${words[1],,} ;;
        *)   nickname=${words[-2],,}-${words[1],,} ;;
      esac
      break
    fi
  done

  # check if nickname is set and if the email is not already present
  if [[ -v nickname ]] && ! grep -Fqs -- "${line[-1]}" $alias_file; then
    count=$(grep -cs "^alias $nickname\(-[[:digit:]]\+\)\? " $alias_file)

    # if nickname already exist append count as suffix
    if [[ -z $count || $count == 0 ]]; then
      printf "%s\n" "alias $nickname ${line[*]:1}" >> $alias_file
    else
      printf "%s\n" "alias $nickname-$count ${line[*]:1}" >> $alias_file
    fi
  fi
}

# pass stdin to create_alias and stdout
tee >(create_alias)
