#!/bin/bash

URL='https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz'
SHA='https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf_0.62.0_checksums.txt'

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

tar=$(basename "$URL")
printf -v tar '%q' "$tar"

curl -sSL "$URL" -o "$tar"
curl -sSL "$SHA" -o checksum
grep "$tar\$" checksum > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"

tar xf "$tar"

install -m 0755 -d ~/bin
install -m 0755 ./fzf ~/bin/fzf

if ! grep -qF 'fzf --bash' ~/.bashrc &>/dev/null; then
	echo 'source <(fzf --bash)' >> ~/.bashrc
  echo 'Updated ~/.bashrc'
fi
