#!/bin/bash

# Created: 2026-02-09 https://github.com/JasonSFuller/

function info  { echo "INFO:    $*"; }
function warn  { echo "WARNING: $*" >&2; }
function error { echo "ERROR:   $*" >&2; exit 1; }

function usage {
  local cmd
  cmd=$(basename "$0")
  cat <<- EOF
		USAGE:   $cmd <sha245_checksum> [<sha245_checksum>]...
		  Given a SHA256 checksum (or multiple), download the corresponding file(s)
		  to the current directory using the Red Hat Subscription Management API.
		    - https://access.redhat.com/management/api
		    - https://access.redhat.com/articles/3626371
		EXAMPLES:
		  $cmd aac774e5aba1c0275d50e0cc4e0e08eca660a116773280596e0bcb894d2da16d # rhel-9.7-x86_64-dvd.iso
		  $cmd 5925e05c32d8324a72e146a29293d60707571817769de73df63eab8dbd6d3196 # rhel-10.1-x86_64-dvd.iso
		  $cmd ead47d809a1dc55453a61586e148b6ccbb951a1d1eaceaff05f38dcbc6cd8cc4 # ansible-automation-platform-containerized-setup-bundle-2.6-5-x86_64.tar.gz
		EOF
  exit 1
}

if [[ $# -gt 0 ]]; then checksums=("${@}"); else usage; fi

for cmd in curl jq sha256sum install; do
  command -v "$cmd" >/dev/null 2>&1 || error "required command is missing: $cmd"
done

if [[ -r "$HOME/.rhsm_offline_token" ]]; then
  info "Reading offline token ($HOME/.rhsm_offline_token)..."
  offline_token=$(< "$HOME/.rhsm_offline_token")
else
  echo "1. Log in:  https://access.redhat.com/management/api"
  echo "2. Click the 'Generate Token' button and paste it below."
  read -r -p '3. Enter offline token: ' offline_token
  echo
  install -m 0600 <(echo "$offline_token") "$HOME/.rhsm_offline_token"
  info "Saved offline token: $HOME/.rhsm_offline_token"
fi

access_json=$(
  curl https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
    -d grant_type=refresh_token \
    -d client_id=rhsm-api \
    -d refresh_token="$offline_token" \
    2>/dev/null
)
access_token=$(jq -r .access_token <<< "$access_json")

if [[ -z "$access_token" || "$access_token" == 'null' ]]; then
  rm -f "$HOME/.rhsm_offline_token"
  error "Authentication failed; access token: $access_token; JSON: $access_json"
fi

for checksum in "${checksums[@]}"
do

  if [[ ! "$checksum" =~ ^[a-fA-F0-9]{64}$ ]]; then
    error "Invalid sha256 checksum ($checksum)"
  fi

  download_json=$(
    curl "https://api.access.redhat.com/management/v1/images/$checksum/download" \
      --header "Authorization: Bearer $access_token" \
      2>/dev/null
  )

  file=$(jq -r .body.filename <<< "$download_json")
  url=$(jq -r .body.href <<< "$download_json")
  if [[ -r "$file" && -r "${file}.sha256" ]]; then
    info "Found existing $file; skipping download"
  else
    info "Downloading ${file} from ${url}"
    curl "$url" -o "$file" --progress-bar
  fi

  info "Verifying checksum ($checksum)"
  if [[ ! -f "${file}.sha256" ]]; then
    echo "$checksum *$file" > "${file}.sha256"
  fi
  if ! sha256sum -c "${file}.sha256"; then
    rm -f "$file" "${file}.sha256"
    error "Checksum MISMATCH!  Download failed.  Try again."
  fi

done
