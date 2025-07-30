#!/bin/bash

URL='https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz'

################################################################################

function error { echo "ERROR: $*" >&2; exit 1; }

function cleanup {
  cd || error "could not open home dir ($HOME)"
  rm -rf "$dir"
}

################################################################################

set -e
trap cleanup INT EXIT
dir=$(mktemp -d)
cd "$dir" || error "could not open temp dir ($dir)"

tar=$(basename "$URL")
printf -v tar '%q' "$tar"

curl -sSL "$URL" -o "$tar"
tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 bat-*-x86_64-unknown-linux-musl/bat ~/bin/bat

if ! grep -qF '.bash_aliases' ~/.bashrc; then
  cmd='\nif [[ -f ~/.bash_aliases ]]; then source ~/.bash_aliases; fi'
  echo -e "$cmd" >> ~/.bashrc
fi
if ! grep -qF 'alias cat=' ~/.bash_aliases; then
  cmd='\nalias cat="bat --decorations never --paging never"'
  echo -e "$cmd" >> ~/.bash_aliases
fi
