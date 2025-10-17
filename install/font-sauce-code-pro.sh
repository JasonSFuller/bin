#!/bin/bash

URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.tar.xz"

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

install -m 0755 -d ~/.fonts/
install -m 0644 \
  SauceCodeProNerdFont-BoldItalic.ttf \
  SauceCodeProNerdFont-Bold.ttf \
  SauceCodeProNerdFont-Italic.ttf \
  SauceCodeProNerdFont-Regular.ttf \
	~/.fonts/
fc-cache -f
