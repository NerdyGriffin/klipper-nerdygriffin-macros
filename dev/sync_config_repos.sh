#!/usr/bin/env bash
# Push each printer's config repo, then refresh the read-only peer config clone on both hosts.
# The clones meet at GitHub, so both pushes run before either pull.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_config_repos.sh
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

echo "[sync_config_repos] Host: $LOCAL_HOST  Peer: $PEER_SSH"

# Nothing is committed here: uncommitted edits stay local and are only reported.
push_config() {
  local target=$1
  local ahead dirty
  if [[ ! -d "$target/.git" ]]; then
    echo "WARN: Config repo not found at $target"
    return 0
  fi
  dirty=$(git -C "$target" status --porcelain --untracked-files=no | wc -l)
  if [[ "$dirty" -gt 0 ]]; then
    echo "NOTE: $dirty uncommitted path(s) in $target will not reach the other host"
  fi
  ahead=$(git -C "$target" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
  if [[ "$ahead" -gt 0 ]]; then
    echo "--- Pushing $ahead commit(s): $target"
    git -C "$target" push
  else
    echo "--- Nothing to push: $target"
  fi
}

peer_failed() {
  echo "ERROR: Peer sync failed on $PEER_SSH. Check the git output above, or PEER_SSH in dev/.env, host keys, and SSH keys." >&2
  exit 1
}

push_config "$CONFIG_DIR"

echo "--- Pushing on peer: $PEER_SSH:$PEER_CONFIG_DIR"
ssh "$PEER_SSH" 'bash -s' <<REMOTE || peer_failed
set -euo pipefail
$(declare -f push_config)
push_config "$PEER_CONFIG_DIR"
REMOTE

"$DEV_DIR/sync_peer_config.sh"

echo "--- Refreshing the peer's clone of this config: $PEER_SSH"
ssh "$PEER_SSH" "$PEER_MACROS_DIR/dev/sync_peer_config.sh" || peer_failed

printf "\n[Done]\n"
