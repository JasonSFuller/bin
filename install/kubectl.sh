#!/bin/bash

LATEST=$(curl -sL https://dl.k8s.io/release/stable.txt)
URL="https://dl.k8s.io/release/${LATEST}/bin/linux/amd64/kubectl"
SHA="https://dl.k8s.io/release/${LATEST}/bin/linux/amd64/kubectl.sha256"

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

exe=$(basename "$URL")

curl -sSL "$URL" -o "$exe"
curl -sSL "$SHA" -o checksum
echo " *$exe" >> checksum
sha256sum -c checksum || error "Invalid checksum"

install -m 0755 -d ~/bin
install -m 0755 "$exe" ~/bin/kubectl

