#!/usr/bin/env bash
set -euo pipefail

# Sync macros repo on both hosts (local + VT-1548 via SSH)
# - Pulls latest changes in:
#   - Local:  /home/pi/klipper-nerdygriffin-macros
#   - Remote: /home/pi/klipper-nerdygriffin-macros (over SSH)
# - Optional: pass a branch name (default: current branch)
# - Requires that SSH host alias "vt-1548" is reachable

BRANCH_ARG=${1:-}

echo "[sync_printer_repo] Host: $(hostname)"

LOCAL_PATH="/home/pi/klipper-nerdygriffin-macros"
REMOTE_HOST="vt-1548"
REMOTE_PATH="/home/pi/klipper-nerdygriffin-macros"

pull_repo() {
  local target=$1
  echo "--- Pulling: $target"
  if [[ -n "$BRANCH_ARG" ]]; then
    git -C "$target" fetch --all
    git -C "$target" checkout "$BRANCH_ARG" || true
    git -C "$target" pull --ff-only || git -C "$target" pull --rebase || true
  else
    git -C "$target" pull --ff-only || git -C "$target" pull --rebase || true
  fi
  git -C "$target" status --short --branch || true
}

# Local pull
if [[ -d "$LOCAL_PATH/.git" ]]; then
  pull_repo "$LOCAL_PATH"
else
  echo "WARN: Local macros repo not found at $LOCAL_PATH"
fi

# Remote pull via SSH
echo "--- Pulling on remote: $REMOTE_HOST:$REMOTE_PATH"
ssh "$REMOTE_HOST" 'bash -s' << EOF
set -euo pipefail
BRANCH_ARG="$BRANCH_ARG"
$(declare -f pull_repo)
if [[ -d "$REMOTE_PATH/.git" ]]; then
  pull_repo "$REMOTE_PATH"
else
  echo "WARN: Remote macros repo not found at $REMOTE_PATH"
fi
EOF
if [[ $? -ne 0 ]]; then
  echo "ERROR: SSH to $REMOTE_HOST failed. Ensure host alias resolves and SSH keys are configured."
fi

printf "\n[Done]\n"
