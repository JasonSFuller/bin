#!/bin/bash

function info  { echo "INFO:  $*"; }
function error { echo "ERROR: $*" >&2; exit 1; }

function cleanup {
  cd || error "could not open home dir ($HOME)"
  rm -rf "$__common_tmp_dir"
}

function init {
  set -e
  trap cleanup INT EXIT
  __common_tmp_dir=$(mktemp -d)
  cd "$__common_tmp_dir" || error "could not open temp dir ($__common_tmp_dir)"
}

function create_bash_aliases_file {
  if ! grep -qF '.bash_aliases' ~/.bashrc &>/dev/null; then
    echo 'if [[ -f ~/.bash_aliases ]]; then source ~/.bash_aliases; fi' >> ~/.bashrc
    echo 'Updated ~/.bashrc:  added .bash_aliases inclusion'
  fi
}

function add_bash_aliases {
  local alias aliases=("$@")
  create_bash_aliases_file
  for alias in "${aliases[@]}"; do
    if ! grep -qF "alias $alias" ~/.bash_aliases &>/dev/null; then
      echo "alias $alias" >> ~/.bash_aliases
      echo "Updated ~/.bash_aliases: alias $alias"
    fi
  done
}

function create_bashrc_d_stub {
  if ! grep -qF '.bashrc.d' ~/.bashrc &>/dev/null; then
    printf '%s\n' \
      'if stat ~/.bashrc.d/*.sh &>/dev/null; then' \
      '  for rc in ~/.bashrc.d/*.sh; do' \
      '    if [[ -r "$rc" ]]; then source "$rc"; fi' \
      '  done' \
      '  unset -v rc' \
      'fi' \
      >> ~/.bashrc
    echo 'Updated ~/.bashrc:  added .bashrc.d/ inclusion'
  fi
}
