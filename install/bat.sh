#!/bin/bash

URL='https://github.com/sharkdp/bat/releases/download/v0.23.0/bat-v0.23.0-x86_64-unknown-linux-musl.tar.gz'

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
install -m 0755 bat-*-x86_64-unknown-linux-musl/bat ~/bin/bat

echo "Don't forget to set an alias for 'cat' in your ~/.bashrc:"
echo "  alias cat='bat --decorations never --paging never'"

