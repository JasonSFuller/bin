#!/bin/bash

URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.tar.xz"

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

install -m 0755 -d ~/.fonts/
install -m 0644 \
  SauceCodeProNerdFont-BoldItalic.ttf \
  SauceCodeProNerdFont-Bold.ttf \
  SauceCodeProNerdFont-Italic.ttf \
  SauceCodeProNerdFont-Regular.ttf \
	~/.fonts/
fc-cache -f

