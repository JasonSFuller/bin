#!/bin/bash

URL='https://github.com/containers/podman/releases/latest/download/podman-remote-static-linux_amd64.tar.gz'
SHA='https://github.com/containers/podman/releases/latest/download/shasums'

################################################################################

function error { echo "ERROR: $*" >&2; exit 1; }

function cleanup {
  cd || error "could not open home dir ($HOME)"
  # rm -rf "$dir"
}

################################################################################

set -e
trap cleanup INT EXIT
dir=$(mktemp -d)
cd "$dir" || error "could not open temp dir ($dir)"

tar=$(basename "$URL")
printf -v tar '%q' "$tar"

curl -fsSL "$URL" -o "$tar"
curl -fsSL "$SHA" -o checksum
grep "$tar\$" checksum > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"

tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 bin/podman-remote-static-linux_amd64 ~/bin/podman-remote

echo "Don't forget to set an alias for 'podman' in your ~/.bashrc:"
echo "  alias podman='podman-remote"
