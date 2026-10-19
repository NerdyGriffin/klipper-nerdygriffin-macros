#!/usr/bin/env bash
# Clone or fast-forward the read-only clone of the peer printer's config repo.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_peer_config.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

echo "[sync_peer_config] Host: $LOCAL_HOST  Peer repo: $PEER_CONFIG_REPO"

if [[ ! -d "$PEER_CONFIG_CLONE/.git" ]]; then
  echo "--- Cloning into: $PEER_CONFIG_CLONE"
  git clone -v "$PEER_CONFIG_REPO" "$PEER_CONFIG_CLONE"
else
  dirty=$(git -C "$PEER_CONFIG_CLONE" status --porcelain)
  if [[ -n "$dirty" ]]; then
    echo "ERROR: $PEER_CONFIG_CLONE has local changes. It is a read-only reference;" >&2
    echo "       edit the peer's config on the peer host and push, then retry." >&2
    echo "$dirty" >&2
    exit 1
  fi
  echo "--- Pulling: $PEER_CONFIG_CLONE"
  if [[ -n "$BRANCH_ARG" ]]; then
    git -C "$PEER_CONFIG_CLONE" fetch --all
    git -C "$PEER_CONFIG_CLONE" checkout "$BRANCH_ARG"
  fi
  git -C "$PEER_CONFIG_CLONE" pull --ff-only
fi

git -C "$PEER_CONFIG_CLONE" status --short --branch
echo "--- Peer config at: $(git -C "$PEER_CONFIG_CLONE" log -1 --format='%h %s')"

printf "\n[Done]\n"
