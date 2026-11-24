#!/usr/bin/env bash
# Push local macros commits, then git-pull the macros repo locally and on the peer host over SSH.
# The KlipperScreen add-on repo (ADDON_DIR) gets the same push/pull, non-fatally, and its
# install.sh -t is re-run after a pull so renamed icons are relinked.
# A failed push or pull is recorded and the remaining repos are still attempted; the script then
# exits non-zero. A summary of each push and pull is printed last.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_macros_repo.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

results_init

echo "[sync_macros_repo] Host: $LOCAL_HOST  Peer: $PEER_SSH"

# push_repo <dir> [status recorded on failure, default FAIL]
push_repo() {
  local target=$1 onfail=${2:-FAIL}
  local ahead name
  name=$(repo_name "$target")
  ahead=$(git -C "$target" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
  if [[ "$ahead" -eq 0 ]]; then
    result OK push "$name" "nothing to push"
    return 0
  fi
  echo "--- Pushing $ahead commit(s): $target"
  if git -C "$target" push; then
    result OK push "$name" "$ahead commit(s)"
  else
    result "$onfail" push "$name" "git push failed"
    return 1
  fi
}

# pull_repo <dir>
pull_repo() {
  local target=$1 name before after
  name=$(repo_name "$target")
  echo "--- Pulling: $target"
  before=$(git -C "$target" rev-parse --short HEAD)
  if [[ -n "$BRANCH_ARG" ]]; then
    if ! git -C "$target" fetch --all || ! git -C "$target" checkout "$BRANCH_ARG"; then
      result FAIL pull "$name" "could not check out $BRANCH_ARG"
      return 1
    fi
  fi
  if ! git -C "$target" pull --ff-only; then
    result FAIL pull "$name" "git pull --ff-only failed"
    return 1
  fi
  git -C "$target" status --short --branch
  after=$(git -C "$target" rev-parse --short HEAD)
  if [[ "$before" == "$after" ]]; then
    result OK pull "$name" "up to date ($after)"
  else
    result OK pull "$name" "$before -> $after"
  fi
}

# Add-on repo: never takes the branch argument, and a failure (e.g. origin not reachable)
# must not abort the macros sync.
sync_addon() {
  local target=$1 name before after
  name=$(repo_name "$target")
  if [[ ! -d "$target/.git" ]]; then
    echo "--- No KlipperScreen add-on repo at $target; skipping"
    result SKIP pull "$name" "no repo"
    return 0
  fi
  before=$(git -C "$target" rev-parse --short HEAD)
  push_repo "$target" WARN || echo "WARN: add-on push failed; continuing"
  if ! git -C "$target" fetch -q origin || ! git -C "$target" merge -q --ff-only '@{u}'; then
    echo "WARN: add-on pull failed at $target; continuing"
    result WARN pull "$name" "pull failed"
    return 0
  fi
  after=$(git -C "$target" rev-parse --short HEAD)
  echo "--- Add-on: $before -> $after ($target)"
  if [[ "$before" == "$after" ]]; then
    result OK pull "$name" "up to date ($after)"
  else
    result OK pull "$name" "$before -> $after"
  fi
  if [[ "$before" != "$after" && -x "$target/install.sh" ]]; then
    if "$target/install.sh" -t >/dev/null; then
      echo "--- Add-on relinked; restart KlipperScreen to load it"
    else
      echo "WARN: add-on install.sh failed at $target; continuing"
    fi
  fi
}

if [[ -d "$MACROS_DIR/.git" ]]; then
  push_repo "$MACROS_DIR" || true
  pull_repo "$MACROS_DIR" || true
else
  echo "WARN: Local macros repo not found at $MACROS_DIR"
  result SKIP pull "$(repo_name "$MACROS_DIR")" "no repo"
fi
sync_addon "$ADDON_DIR"

echo "--- Pulling on peer: $PEER_SSH:$PEER_MACROS_DIR"
fails_before=$(results_count FAIL)
if ! ssh "$PEER_SSH" 'bash -s' <<REMOTE | collect_results
set -euo pipefail
BRANCH_ARG="$BRANCH_ARG"
LOCAL_HOST="$PEER_HOST"
SYNC_FAILED=0
$(declare -f result)
$(declare -f repo_name)
$(declare -f push_repo)
$(declare -f pull_repo)
$(declare -f sync_addon)
if [[ -d "$PEER_MACROS_DIR/.git" ]]; then
  pull_repo "$PEER_MACROS_DIR" || true
else
  echo "WARN: Peer macros repo not found at $PEER_MACROS_DIR"
  result SKIP pull "\$(repo_name "$PEER_MACROS_DIR")" "no repo"
fi
sync_addon "$PEER_ADDON_DIR"
exit "\$SYNC_FAILED"
REMOTE
then
  if [[ $(results_count FAIL) -eq $fails_before ]]; then
    result FAIL pull "$(repo_name "$MACROS_DIR")" "ssh to $PEER_SSH failed" "$PEER_HOST"
  fi
  SYNC_FAILED=1
  echo "ERROR: Peer sync failed on $PEER_SSH. Check the git output above, or PEER_SSH in dev/.env, host keys, and SSH keys." >&2
fi

printf "\n[Done]\n"
exit "$SYNC_FAILED"
