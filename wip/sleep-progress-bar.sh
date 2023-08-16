#!/bin/bash

################################################################################
#
#   !!! WARNING !!!  This is a WIP and not done yet.
#
################################################################################

function error { echo "ERROR: $*" >&2; exit 1; }
function progress_bar
{
  local i t l p c f 
  i=$1 # current iteration (e.g. position i of t units)
  t=$2 # total number of units
  l=$3 # progress bar length (in chars)
  if [[ ! "$i" =~ ^[0-9]+$ ]]; then error "invalid param"; fi
  if [[ ! "$t" =~ ^[0-9]+$ ]]; then error "invalid param"; fi
  if [[ ! "$l" =~ ^[0-9]+$ ]]; then l=40; fi
  if (( t < 1 )); then error "invalid param"; fi
  if (( l < 1 )); then error "invalid param"; fi
  p=$(( i * 100 / t )) # percentage
  c=$(( l * p / 100 )) # bar's current position (in chars)
  f=$(( l - c ))       # bar's remaining fill (in chars)
  
  # https://en.wikipedia.org/wiki/ANSI_escape_code
  #   \r   = move cursor to column 0
  #   \e[K = clear from cursor to EOL
  printf "\r\e[K"
  printf "["
  head -c "$c" < /dev/zero | tr '\0' '='
  head -c "$f" < /dev/zero | tr '\0' ' '
  printf "] %3d%% (%d/%d)" "$p" "$i" "$t"

  if [[ "$i" -eq "$t" ]]; then printf " DONE\n"; fi
}

################################################################################

sec=$1

if [[ ! "$sec" =~ ^[0-9]+$ || $sec -lt 1 ]]; then
  echo "ERROR: first argument (seconds) must be a positive integer" >&2
  exit 1
fi

echo "Sleeping for $sec second(s)"

progress_bar 0 "$sec" # show initial bar before sleeping
while [[ $i -lt $sec ]]
do
  ((i++))
  sleep 1
  progress_bar "$i" "$sec"
done
