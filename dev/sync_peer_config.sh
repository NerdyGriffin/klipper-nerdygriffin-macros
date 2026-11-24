#!/usr/bin/env bash
# Clone or fast-forward the read-only clone of the peer printer's config repo.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_peer_config.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}
CLONE_NAME=$(basename "$PEER_CONFIG_REPO" .git)

results_init

echo "[sync_peer_config] Host: $LOCAL_HOST  Peer repo: $PEER_CONFIG_REPO"

if [[ ! -d "$PEER_CONFIG_CLONE/.git" ]]; then
  echo "--- Cloning into: $PEER_CONFIG_CLONE"
  if ! git clone -v "$PEER_CONFIG_REPO" "$PEER_CONFIG_CLONE"; then
    result FAIL pull "$CLONE_NAME" "git clone failed"
    exit 1
  fi
  result OK pull "$CLONE_NAME" "cloned ($(git -C "$PEER_CONFIG_CLONE" rev-parse --short HEAD))"
else
  dirty=$(git -C "$PEER_CONFIG_CLONE" status --porcelain --untracked-files=no)
  if [[ -n "$dirty" ]]; then
    echo "ERROR: $PEER_CONFIG_CLONE has local changes. It is a read-only reference;" >&2
    echo "       edit the peer's config on the peer host and push, then retry." >&2
    echo "$dirty" >&2
    result FAIL pull "$CLONE_NAME" "local changes in the read-only clone"
    exit 1
  fi
  echo "--- Pulling: $PEER_CONFIG_CLONE"
  before=$(git -C "$PEER_CONFIG_CLONE" rev-parse --short HEAD)
  if [[ -n "$BRANCH_ARG" ]]; then
    if ! git -C "$PEER_CONFIG_CLONE" fetch --all || ! git -C "$PEER_CONFIG_CLONE" checkout "$BRANCH_ARG"; then
      result FAIL pull "$CLONE_NAME" "could not check out $BRANCH_ARG"
      exit 1
    fi
  fi
  if ! git -C "$PEER_CONFIG_CLONE" pull --ff-only; then
    result FAIL pull "$CLONE_NAME" "git pull --ff-only failed"
    exit 1
  fi
  after=$(git -C "$PEER_CONFIG_CLONE" rev-parse --short HEAD)
  if [[ "$before" == "$after" ]]; then
    result OK pull "$CLONE_NAME" "up to date ($after)"
  else
    result OK pull "$CLONE_NAME" "$before -> $after"
  fi
fi

git -C "$PEER_CONFIG_CLONE" status --short --branch
echo "--- Peer config at: $(git -C "$PEER_CONFIG_CLONE" log -1 --format='%h %s')"

printf "\n[Done]\n"
