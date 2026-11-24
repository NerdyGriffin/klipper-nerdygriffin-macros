#!/usr/bin/env bash
# Push each printer's config repo, then refresh the read-only peer config clone on both hosts.
# The clones meet at GitHub, so both pushes run before either pull.
# A failed step is recorded and the remaining ones are still attempted; the script then exits
# non-zero. A summary of each push and pull is printed last.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_config_repos.sh
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

results_init

echo "[sync_config_repos] Host: $LOCAL_HOST  Peer: $PEER_SSH"

# Nothing is committed here: uncommitted edits stay local and are only reported.
push_config() {
  local target=$1
  local ahead dirty name status=OK note=""
  name=$(repo_name "$target")
  if [[ ! -d "$target/.git" ]]; then
    echo "WARN: Config repo not found at $target"
    result SKIP push "$name" "no repo"
    return 0
  fi
  dirty=$(git -C "$target" status --porcelain --untracked-files=no | wc -l)
  if [[ "$dirty" -gt 0 ]]; then
    echo "NOTE: $dirty uncommitted path(s) in $target will not reach the other host"
    status=WARN
    note="; $dirty uncommitted path(s) not synced"
  fi
  ahead=$(git -C "$target" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
  if [[ "$ahead" -gt 0 ]]; then
    echo "--- Pushing $ahead commit(s): $target"
    if git -C "$target" push; then
      result "$status" push "$name" "$ahead commit(s)$note"
    else
      result FAIL push "$name" "git push failed$note"
    fi
  else
    echo "--- Nothing to push: $target"
    result "$status" push "$name" "nothing to push$note"
  fi
}

# peer_failed <action> <repo> <FAIL count before the ssh call>
peer_failed() {
  if [[ $(results_count FAIL) -eq $3 ]]; then
    result FAIL "$1" "$2" "ssh to $PEER_SSH failed" "$PEER_HOST"
  fi
  SYNC_FAILED=1
  echo "ERROR: Peer sync failed on $PEER_SSH. Check the git output above, or PEER_SSH in dev/.env, host keys, and SSH keys." >&2
}

PEER_CONFIG_NAME=$(basename "$PEER_CONFIG_REPO" .git)
CONFIG_NAME=$(repo_name "$CONFIG_DIR")

push_config "$CONFIG_DIR"

echo "--- Pushing on peer: $PEER_SSH:$PEER_CONFIG_DIR"
fails_before=$(results_count FAIL)
ssh "$PEER_SSH" 'bash -s' <<REMOTE | collect_results || peer_failed push "$PEER_CONFIG_NAME" "$fails_before"
set -euo pipefail
LOCAL_HOST="$PEER_HOST"
SYNC_FAILED=0
$(declare -f result)
$(declare -f repo_name)
$(declare -f push_config)
push_config "$PEER_CONFIG_DIR"
exit "\$SYNC_FAILED"
REMOTE

"$DEV_DIR/sync_peer_config.sh" || SYNC_FAILED=1

echo "--- Refreshing the peer's clone of this config: $PEER_SSH"
fails_before=$(results_count FAIL)
rows_before=$(results_count)
if ssh "$PEER_SSH" "SYNC_RESULTS_STDOUT=1 $PEER_MACROS_DIR/dev/sync_peer_config.sh" | collect_results; then
  # A peer still on an older copy of the script reports nothing itself.
  if [[ $(results_count) -eq $rows_before ]]; then
    result OK pull "$CONFIG_NAME" "no detail reported by the peer" "$PEER_HOST"
  fi
else
  peer_failed pull "$CONFIG_NAME" "$fails_before"
fi

printf "\n[Done]\n"
exit "$SYNC_FAILED"
