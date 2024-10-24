#!/bin/bash

# Install code-server RPM (RHEL, CentOS, etc)

function info  { echo "[INFO]  $*"; }
function error { echo "[ERROR] $*" >&2; exit 1; }

if [[ "$(id -u)" != '0' ]]; then
  error 'must be run as root'
fi

# Stop if you encounter any errors
set -e

api='https://api.github.com/repos/coder/code-server/releases/latest'
query='.assets[] | select(.content_type == "application/x-redhat-package-manager") | select(.name | contains("amd64")) | { name, size, browser_download_url }'
json=$(curl -fsSL "$api")
json=$(jq -r "$query" <<< "$json")
url=$(jq -r '.browser_download_url' <<< "$json")
file="/tmp/$(jq -r '.name' <<< "$json")"
size=$(jq -r '.size' <<< "$json")

if [[ ! "$url" =~ ^https://github.com/coder/code-server/releases/ ]]; then
  error "invalid download url: $url"
fi
info "Downloading: $url"
info "         to: $file"
curl -sSL "$url" -o "$file"
dl_size=$(stat -c %s "$file")
if [[ "$size" != "$dl_size" ]]; then
  error 'file size mismatch'
fi

old=$(rpm -q code-server)
dnf install -y "$file"
new=$(rpm -q code-server)

info "Restarting code-server instances"
systemctl restart 'code-server*' # should all be per-user systemd instances

info "Updated from: $old"
info "          to: $new"

rm -f "$file"

