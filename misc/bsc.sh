#!/bin/bash

###############################################################################
#                         Invoke BSC Compiler over SSH                        #
###############################################################################

SSH_SERVER=ISP-Pool
DIRECTORY=bluespec_tmp
DIRECTORY_SIZE_LIMIT=10M
PRE_EXEC="\
    PATH=\$PATH:/opt/bluespec/bin && \
    export BLUESPECDIR=/opt/bluespec/lib && \
    export LM_LICENSE_FILE=27000@licence.rbg.informatik.tu-darmstadt.de"

function exec_remote(){
    ssh -q $SSH_SERVER "$PRE_EXEC && cd $DIRECTORY && $@"
}

function copy_to_remote(){
    scp -pqr "$@" $SSH_SERVER:$DIRECTORY
}

function copy_from_remote(){
    for file in $@; do
        scp -pqr $SSH_SERVER:"$DIRECTORY/$file" "$file" 
    done
}

function check(){
    local DIRECTORY_BYTE_SIZE=$(du -sb $PWD | awk '{print $1;}')
    local DIRECTORY_BYTE_SIZE_LIMIT=$(numfmt --from=iec $DIRECTORY_SIZE_LIMIT)
    if [[ $DIRECTORY_BYTE_SIZE -gt $DIRECTORY_BYTE_SIZE_LIMIT ]]; then
        echo "Directory exceeds size limit of $DIRECTORY_SIZE_LIMIT! Aborting."
        exit 1
    fi
}

check
copy_to_remote "$PWD"
last_modified=$(exec_remote "stat -c '%Y' \$(find * -type f) | sort -nr | head -n 1")
exec_remote "bsc $@"
files_to_copy=$(exec_remote \
    "for file in \$(find * -type f); do \
         if [[ \$(stat -c '%Y' \"\$file\") -gt $last_modified ]]; then \
             echo \"\$file\"; \
         fi \
     done")
copy_from_remote "$files_to_copy"
exec_remote 'rm -r $PWD'
