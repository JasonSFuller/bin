#!/bin/bash

URL='https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-musl.tar.gz'

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

tar=$(basename "$URL")

curl -fsSL "$URL" -o "$tar"
tar xf "$tar"

install -m 0755 -d ~/bin
install -m 0755 delta-*-x86_64-unknown-linux-musl/delta ~/bin/delta
