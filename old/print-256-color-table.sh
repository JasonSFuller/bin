#!/bin/bash

printf '\n0 -  7 = original 4-bit colors'
printf '\n8 - 15 = "bold"/intense colors\n'
for i in {0..15}; do
  if [[ $((i%8)) == 0 ]]; then printf '\n'; fi
  if ((i%8)); then tput setaf 0; else tput setaf 7; fi
  tput setab "$i"; printf ' %2d ' "$i"; tput sgr0
  tput setaf "$i"; printf ' %2d ' "$i"; tput sgr0
done

printf '\n\n16 - 231 = 216 colors = 6x6x6 3-dimensional RGB cube'
for i in {16..231}; do
  if [[ $((i%6)) == 4 ]]; then printf '\n'; fi
  if [[ $((i%36)) == 16 ]]; then printf '\n'; fi
  tput setab "$i"; printf ' %3d ' "$i"; tput sgr0
  tput setaf "$i"; printf ' %3d ' "$i"; tput sgr0
done

printf '\n\n232 - 255 = grays\n'
for i in {232..255}; do
  if [[  $((i%6)) ==  4 ]]; then printf '\n'; fi
  ## middle grays are hard to see without an offset
  #if [[ "$i" -lt 244 ]]; then o=$(((i-232)/2)); else o=$((0-(255-i+1)/2)); fi
  #tput setaf "$(( 255+232-i+o ))"
  if [[ "$i" -ge 232 && "$i" -le 243 ]]; then tput setaf 7; fi
  if [[ "$i" -ge 244 && "$i" -le 255 ]]; then tput setaf 0; fi
  tput setab "$i"; printf ' %3d ' "$i"; tput sgr0
  tput setaf "$i"; printf ' %3d ' "$i"; tput sgr0
done

printf '\n\n'
