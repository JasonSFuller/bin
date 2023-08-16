#!/bin/bash

# | Color            | Character       |
# | ---------------- | --------------- |
# | transparent      | ` ` space       |
# | dark gray        | `_` underscore  |
# | dark white       | `#` number sign |
# | bold/light gray  | `^` caret       |
# | bold/light white | `@` at sign     |

if [[ -f "$1" ]]; then FILE=$1; else FILE=/dev/stdin; fi

gray=$(tput setaf 0; tput setab 0)
white=$(tput setaf 7; tput setab 7)
bgray=$(tput setaf 8; tput setab 8)
bwhite=$(tput setaf 15; tput setab 15)
r=$(tput sgr 0)

sed -r "
  s/( +)/$r\1/g;
  s/(\_+)/$gray\1$r/g;
  s/(\^+)/$bgray\1$r/g;
  s/(\#+)/$white\1$r/g;
  s/(\@+)/$bwhite\1$r/g;
  s/\$/$r/;" < "$FILE"
