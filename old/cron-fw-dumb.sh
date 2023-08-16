#!/bin/bash

BASE=$(basename "$0" .sh)

URL="https://www.google.com"
FWURL="https://palo-alto.silly-company.com:6082/php/uid.php?vsys=1&rule=1&url=$URL"
FWRE='silly-company'
CREDS="$HOME/.$BASE" # get creds from here
COOKIE="$HOME/.$BASE.cookie" # place to store cookies
DRIVE="$HOME/h-drive" # drive to check for
MSG="$DRIVE/tmp/$BASE.txt" # thing to write
LOG="$HOME/.$BASE.log" # private log with sensitive data (your hashed creds)

CURL_OPTS="--insecure --verbose --silent --trace-ascii - --output - --cookie $COOKIE --cookie-jar $COOKIE"

################################################################################

# clear the log and set perms, it may contain cred info
install -m 600 /dev/null "$LOG"

function log   { echo "$*" >> "$LOG"; }
function info  { log "INFO:  $*"; }
function warn  { log "WARN:  $*" >&2; }
function error { log "ERROR: $*"; echo "ERROR: $*" >&2; exit 1; }

if [[ -r "$CREDS" ]]; then
  source "$CREDS"
else
  error "firewall creds missing"
fi

if mountpoint "$DRIVE" >& /dev/null; then

  info "mount detected ($DRIVE)"
  tmpdir=$(dirname "$MSG")
  now=$(date)
  if [[ ! -d "$tmpdir" ]]; then
    info "creating tmp dir ($tmpdir)"
    mkdir -p "$tmpdir"
  fi

  # This doesn't appear to work, since I had to add the URL stuff below this,
  # but it doesn't hurt either.
  info "writing file ($MSG)"
  cat <<- EOF > "$MSG"
	Last written: $now

	----------------------------------------------------------------------
	I'm on Linux and writing to a file every hour so the dumbass
	firewall doesn't block me, because... yeah, THAT's a thing.
	Apparently, Windowsy-type actions--like writing to a shared
	drive that requires your AD credentials--will allow the
	Palo Alto firewall to tie your IP to your AD account, so it
	can determine (and allow/deny) your access to the internet,
	based on whatever profile your account falls under.

	It's safe to delete this file, if you want.  It will be
	rewritten in an hour if my H: drive is locally mounted on my 
	laptop.
	----------------------------------------------------------------------
	
	EOF

  # Apparently web traffic needed too keep the PA aware of my goddamn existence.
  # Try to get to Google, and if not, try to auth to the firewall.
  info "getting '$URL'"
  curl $CURL_OPTS "$URL" >> "$LOG" 2>&1

  # If you found 'silly-company' on the Google page, 
  if grep -qiF "$FWRE" <<< "$LOG"; then
    info "-------------------------"
    info "attempting firewall login"
    info "-------------------------"
    curl $CURL_OPTS "$URL" >> "$LOG" 2>&1
  fi
else
  warn "drive not mounted ($DRIVE)"
fi
