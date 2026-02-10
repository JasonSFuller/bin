#!/bin/bash

################################################################################

self=$(realpath -e "${BASH_SOURCE[0]}")
selfdir=$(dirname "$self")
# shellcheck source=./__common.sh
source "${selfdir}/__common.sh"
init

################################################################################

cat > ssh-agent.sh <<- 'EOF'
function load_ssh_agent {
  echo "starting ssh-agent..."
  ssh-agent | grep -v ^echo > ~/.ssh/agent
  chmod 0600 ~/.ssh/agent
  cat        ~/.ssh/agent
  # shellcheck source=/dev/null
  source     ~/.ssh/agent
}

function check_ssh_agent {
  if [[ ! -d ~/.ssh ]]; then
    if ! install -m 0755 -d ~/.ssh; then
      echo 'ERROR: cannot create ~/.ssh dir' >&2
      return 1
    fi
  fi
  if [[ ! -r ~/.ssh/agent ]]; then
    if ! touch ~/.ssh/agent; then
      echo 'ERROR: cannot create ssh-agent env file' >&2
      return 1
    fi
  fi
  # shellcheck source=/dev/null
  source ~/.ssh/agent
  if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    echo "INFO: no socket found (SSH_AUTH_SOCK=$SSH_AUTH_SOCK)"
    load_ssh_agent
  fi
  if [[ -S "$SSH_AUTH_SOCK" ]] && ! export -p | grep -qF ' SSH_AUTH_SOCK='; then
    export SSH_AUTH_SOCK
  fi
}

check_ssh_agent

unset load_ssh_agent
unset check_ssh_agent
EOF

create_bashrc_d_stub
if [[ ! -f ~/.bashrc.d/ssh-agent.sh ]]; then
  install -m 0644 ssh-agent.sh ~/.bashrc.d/ssh-agent.sh
fi
