#!/usr/bin/env bash

if [[ ! -r path-functions.sh ]]; then
  echo "ERROR: path-functions.sh not found" >&2
  exit 1
fi
source path-functions.sh

function path_test {
  local action="$1"
  local dir="$2"
  printf "path_%s %s\n" "$action" "$dir"
  printf "before: PATH=%s\n" "$PATH"
  case "$action" in
    append)  path_append  "$dir";;
    prepend) path_prepend "$dir";;
    remove)  path_remove  "$dir";;
  esac
  printf "after:  PATH=%s\n\n" "$PATH"
}

# NOTE: /usr/bin required for grep and sed commands (used in functions)
PATH=/one:/two:/usr/bin:/three

path_test append /four
path_test remove /three
path_test prepend /four
path_test prepend /abc
path_test append /five/and/a/half
path_test append /four
path_test remove /four
path_test remove /abc
path_test remove /five
path_test remove /a/
path_test remove /half
path_test append "/one\:two"
path_test append "/one:two"
path_test append /six
path_test remove /six
path_test remove /one
path_test remove /five/and/a/half
path_test append /seven
path_test remove '/one\:two'

