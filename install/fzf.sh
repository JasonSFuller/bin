#!/bin/bash

URL='https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz'
SHA='https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf_0.62.0_checksums.txt'

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
curl -sSL "$SHA" -o checksum
grep "$tar\$" checksum > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"

tar xf "$tar"

install -m 0755 -d ~/bin
install -m 0755 ./fzf ~/bin/fzf
