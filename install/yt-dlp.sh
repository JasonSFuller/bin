#!/bin/bash

URL='https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux'
SHA='https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS'

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
install -m 0755 "$exe" ~/bin/yt-dlp
