#!/bin/bash

URL='https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-musl.tar.gz'

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

curl -fsSL "$URL" -o "$tar"
tar xf "$tar"

install -m 0755 -d ~/bin
install -m 0755 delta-0.18.2-x86_64-unknown-linux-musl/delta ~/bin/delta
