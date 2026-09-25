#!/usr/bin/env bash
# Git-pull the macros repo locally and on the peer host over SSH.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_macros_repo.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

echo "[sync_macros_repo] Host: $LOCAL_HOST  Peer: $PEER_SSH"

pull_repo() {
  local target=$1
  echo "--- Pulling: $target"
  if [[ -n "$BRANCH_ARG" ]]; then
    git -C "$target" fetch --all
    git -C "$target" checkout "$BRANCH_ARG" || true
  fi
  git -C "$target" pull --ff-only || git -C "$target" pull --rebase || true
  git -C "$target" status --short --branch || true
}

if [[ -d "$MACROS_DIR/.git" ]]; then
  pull_repo "$MACROS_DIR"
else
  echo "WARN: Local macros repo not found at $MACROS_DIR"
fi

echo "--- Pulling on peer: $PEER_SSH:$PEER_MACROS_DIR"
if ! ssh "$PEER_SSH" 'bash -s' <<REMOTE
set -euo pipefail
BRANCH_ARG="$BRANCH_ARG"
$(declare -f pull_repo)
if [[ -d "$PEER_MACROS_DIR/.git" ]]; then
  pull_repo "$PEER_MACROS_DIR"
else
  echo "WARN: Peer macros repo not found at $PEER_MACROS_DIR"
fi
REMOTE
then
  echo "ERROR: SSH to $PEER_SSH failed. Check PEER_SSH in dev/.env, host keys, and SSH keys."
fi

printf "\n[Done]\n"
