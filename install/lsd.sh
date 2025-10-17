#!/bin/bash

URL='https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-musl.tar.gz'
SHA256SUM='af10fbef2472134c676396a27ecfffb34adb107da2f95d0453a3150ced33ae47'

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
echo "$SHA256SUM *${tar}" > "${tar}.sha256"
sha256sum -c "${tar}.sha256" || error "Invalid checksum"
tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 lsd-*-x86_64-unknown-linux-musl/lsd ~/bin/lsd

add_bash_aliases \
  "l='lsd'" \
  "ls='lsd'" \
  "ll='lsd -la'" \
  "tree='lsd --tree'"
