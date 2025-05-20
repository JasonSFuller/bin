#!/bin/bash

URL='https://github.com/containers/podman/releases/latest/download/podman-remote-static-linux_amd64.tar.gz'
SHA='https://github.com/containers/podman/releases/latest/download/shasums'

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

curl -fsSL "$URL" -o "$tar"
curl -fsSL "$SHA" -o checksum
grep "$tar\$" checksum > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"

tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 bin/podman-remote-static-linux_amd64 ~/bin/podman-remote

echo "Don't forget to set an alias for 'podman' in your ~/.bashrc:"
echo "  alias podman='podman-remote'"
echo "Configure the remote connection for your Podman client:"
echo "  podman system connection add --default podman-machine-default-root unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock"
echo "Give your user permission to the Podman socket (via the 'uucp' group):"
echo "  ls -la /mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock"
echo "  sudo usermod -aG uucp \"$USER\""
echo "Finally, log out/in to update '\$PATH' and your user's group permissions."
