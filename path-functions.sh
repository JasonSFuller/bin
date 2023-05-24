#!/usr/bin/env bash

function path_check_dir {
  local dir="$1"
  # Allow '\:' but not ':' or '\\:'
  if [[ "$dir" =~ [^\\]:|\\\\: ]]; then
    echo "ERROR: unescaped colons not allowed" >&2
    return 1
  fi
}

# Append a dir to the end of $PATH
function path_append {
  local dir="$1"
  path_check_dir "$dir" || return "$?"
  if [[ ":$PATH:" == *":$dir:"* ]]; then return; fi # already exists, skip
  PATH="$PATH:$dir"
}

# Prepend a dir to the beginning of $PATH
function path_prepend {
  local dir="$1"
  path_check_dir "$dir" || return "$?"
  if [[ ":$PATH:" == *":$dir:"* ]]; then return; fi # already exists, skip
  PATH="$dir:$PATH"
}

# Remove a dir from $PATH
function path_remove {
  local dir="$1"
  # IMPORTANT:  Removal is much more difficult because of special characters.
  #   Convert colons (ignoring escaped colons) to nulls, remove fixed whole line
  #   matches, remove empty lines, and then convert nulls back to colons.
  #   Remember that Bash variables CANNOT store nulls, and that they are invalid
  #   file and directory names.
  PATH=$(
    echo -n "$PATH" \
    | sed -r 's/([^\\]):/\1\x0/g' \
    | grep -vzFx "$dir" \
    | grep -vz '^$' \
    | sed -r 's/\x0/:/g'
  )
  # Trim a single leading and trailing colon
  PATH="${PATH#:}"
  PATH="${PATH%:}"
}

