#!/usr/bin/env bash
# Mount the peer, sync the macros repo on both hosts, then verify.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_all.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

printf "[sync_all] Host: %s\n" "$LOCAL_HOST"

printf "\n1) Mount peer config (per fstab)\n"
"$DEV_DIR/mount_printers.sh"

printf "\n2) Sync macros repo on both hosts\n"
if [[ -n "$BRANCH_ARG" ]]; then
  "$DEV_DIR/sync_macros_repo.sh" "$BRANCH_ARG"
else
  "$DEV_DIR/sync_macros_repo.sh"
fi

printf "\n3) Verify mounts and permissions\n"
"$DEV_DIR/verify_printers.sh"

printf "\n[Done]\n"
