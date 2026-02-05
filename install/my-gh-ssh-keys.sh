#!/bin/bash

keys=$(curl -sfL "https://github.com/jasonsfuller.keys") \
  || { echo "ERROR: failed to get keys from Github"; exit 1; }

if [[ -f ~/.ssh/authorized_keys ]]; then
  cp  -a ~/.ssh/authorized_keys{,.$(date +%Y%m%d%H%M%S)}
fi

echo "$keys"

install -m 0755              -d ~/.ssh
install -m 0644 <(echo "$keys") ~/.ssh/authorized_keys

if builtin command -v restorecon &>/dev/null; then
  restorecon -R ~/.ssh
fi
