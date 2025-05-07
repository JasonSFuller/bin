#!/bin/bash

function error { echo "ERROR: $*" >&2; exit 1; }
cd /tmp || error 'cannot access /tmp'

FILE='viu'
URL='https://github.com/atanunq/viu/releases/latest/download/viu-x86_64-unknown-linux-musl'
curl -fsSLo "$FILE" "$URL"
install -m 0755 "$FILE" ~/bin/

