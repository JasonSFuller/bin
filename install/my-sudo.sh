#!/bin/bash

# don't require a sudo password for my account

function error { echo "[ERROR] $*" >&2; exit 1; }

if [[ ! "$USER" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
  error "invalid username ($USER)"
fi

if ! getent passwd "$USER" > /dev/null 2>&1; then
  error "user not found ($USER)"
fi

echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" \
  | sudo install -m 0440 /dev/stdin "/etc/sudoers.d/$USER"

sudo grep --color=always -H ^ "/etc/sudoers.d/$USER"
sudo visudo -c
