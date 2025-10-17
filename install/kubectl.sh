#!/bin/bash

LATEST=$(curl -sL https://dl.k8s.io/release/stable.txt)
URL="https://dl.k8s.io/release/${LATEST}/bin/linux/amd64/kubectl"
SHA="https://dl.k8s.io/release/${LATEST}/bin/linux/amd64/kubectl.sha256"

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

exe=$(basename "$URL")

curl -fsSL "$URL" -o "$exe"
curl -fsSL "$SHA" -o checksum
echo " *$exe" >> checksum
sha256sum -c checksum || error "Invalid checksum"

install -m 0755 -d ~/bin/
install -m 0755 "$exe" ~/bin/kubectl
