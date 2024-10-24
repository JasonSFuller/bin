#!/bin/bash

URL='https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz'

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

curl -sSL "$URL" -o "$tar"
tar xf "$tar"

install -m 0755 -d ~/bin
install -m 0755 shellcheck-*/shellcheck ~/bin/shellcheck

