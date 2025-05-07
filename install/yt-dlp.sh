#!/bin/bash

function error { echo "ERROR: $*" >&2; exit 1; }

cd /tmp || error 'cannot access /tmp'

printf -v FILE '%q' 'yt-dlp_linux'
URL='https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux'
SHA='https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS'

curl -fsSLo "$FILE" "$URL"
checksums=$(curl -fsSL "$SHA")
grep "\s${FILE}\s*$" <<< "$checksums" > "$FILE.sha256"
if ! sha256sum -c "$FILE.sha256"; then error 'checksum failed'; fi
install -m 0755 "$FILE" ~/bin/

