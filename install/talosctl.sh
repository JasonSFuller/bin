#!/bin/bash

URL='https://github.com/siderolabs/talos/releases/download/v1.10.2/talosctl-linux-amd64'
SHA='https://github.com/siderolabs/talos/releases/download/v1.10.2/sha256sum.txt'

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

exe=$(basename "$URL")
printf -v exe '%q' "$exe"

curl -fsSL "$URL" -o "$exe"
curl -fsSL "$SHA" -o checksum
grep "$exe\$" checksum > "${exe}.sha256"
sha256sum -c "${exe}.sha256" || error "Invalid checksum"

install -m 0755 -d ~/bin/
install -m 0755 "$exe" ~/bin/talosctl
