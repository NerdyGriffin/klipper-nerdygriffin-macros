#!/usr/bin/env bash
# Refresh the peer config clone, sync the macros and KlipperScreen add-on repos on both hosts, then verify.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_all.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

printf "[sync_all] Host: %s\n" "$LOCAL_HOST"

printf "\n1) Refresh peer config clone\n"
"$DEV_DIR/sync_peer_config.sh"

printf "\n2) Sync macros and KlipperScreen add-on repos on both hosts\n"
if [[ -n "$BRANCH_ARG" ]]; then
  "$DEV_DIR/sync_macros_repo.sh" "$BRANCH_ARG"
else
  "$DEV_DIR/sync_macros_repo.sh"
fi

printf "\n3) Verify paths\n"
"$DEV_DIR/verify_paths.sh"

printf "\n[Done]\n"
