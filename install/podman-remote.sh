#!/bin/bash

# PURPOSE:  Install when using WSL and you want to interact with the Podman
# Desktop distro from your Ubuntu distro.

URL='https://github.com/containers/podman/releases/latest/download/podman-remote-static-linux_amd64.tar.gz'
SHA='https://github.com/containers/podman/releases/latest/download/shasums'

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

tar=$(basename "$URL")
printf -v tar '%q' "$tar"

curl -fsSL "$URL" -o "$tar"
curl -fsSL "$SHA" -o checksum
grep "$tar\$" checksum > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"

tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 bin/podman-remote-static-linux_amd64 ~/bin/podman-remote

add_bash_aliases "podman='podman-remote'"

echo "Give your user permission to the Podman socket (via the 'uucp' group):"
echo "  ls -la /mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock"
echo "  sudo usermod -aG uucp \"$USER\""
echo "  groups"
echo "Configure the remote connection for your Podman client:"
echo "  podman system connection add --default podman-machine-default-user \\"
echo "    unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-user.sock"
echo "  podman system connection add           podman-machine-default-root \\"
echo "    unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock"
echo "Finally, log out/in to update '\$PATH' and your user's group permissions."
echo "  exit"
