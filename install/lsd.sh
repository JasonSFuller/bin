#!/bin/bash

URL='https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-musl.tar.gz'
SHA256SUM='af10fbef2472134c676396a27ecfffb34adb107da2f95d0453a3150ced33ae47'

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
echo "$SHA256SUM *${tar}" > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"
tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 lsd-*-x86_64-unknown-linux-musl/lsd ~/bin/lsd

if ! grep -qF '.bash_aliases' ~/.bashrc &>/dev/null; then
  cmd='\nif [[ -f ~/.bash_aliases ]]; then source ~/.bash_aliases; fi'
  echo -e "$cmd" >> ~/.bashrc
  echo 'Updated ~/.bashrc'
fi
for i in \
  "l='lsd'" \
  "ls='lsd'" \
  "ll='lsd -la'" \
  "tree='lsd --tree'"
do
  if ! grep -qF "alias $i" ~/.bash_aliases &>/dev/null; then
    echo "alias $i" >> ~/.bash_aliases
    echo 'Updated ~/.bash_aliases'
  fi
done
