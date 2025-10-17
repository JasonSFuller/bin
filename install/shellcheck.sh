#!/bin/bash

URL='https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz'

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

install -m 0755 -d ~/bin/
install -m 0755 shellcheck-*/shellcheck ~/bin/shellcheck
