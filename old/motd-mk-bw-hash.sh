#!/bin/bash

# NOTE: older black/white script for motds; use motd-mk-4bit-gray.sh instead

if [[ -f "$1" ]]; then FILE=$1; else FILE=/dev/stdin; fi

neg=$(tput setaf 7; tput setab 7)
pos=$(tput setaf 7; tput setab 0)
rst=$(tput sgr0)

sed -r "s/^/$pos/; s/(#+)/$neg\1$pos/g; s/\$/$rst/" < "$FILE"
