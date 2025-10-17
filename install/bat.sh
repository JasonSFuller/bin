#!/bin/bash

URL='https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz'

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
tar xf "$tar"

install -m 0755 -d ~/bin/
install -m 0755 bat-*-x86_64-unknown-linux-musl/bat ~/bin/bat

add_bash_aliases "cat='bat --decorations never --paging never'"
