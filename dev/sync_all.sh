#!/usr/bin/env bash
# Sync the macros and KlipperScreen add-on repos, then the config repos and peer config clones, on both
# hosts, then verify. The branch argument applies to the macros repo only.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_all.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

printf "[sync_all] Host: %s\n" "$LOCAL_HOST"

printf "\n1) Sync macros and KlipperScreen add-on repos on both hosts\n"
if [[ -n "$BRANCH_ARG" ]]; then
  "$DEV_DIR/sync_macros_repo.sh" "$BRANCH_ARG"
else
  "$DEV_DIR/sync_macros_repo.sh"
fi

printf "\n2) Sync config repos and peer config clones on both hosts\n"
"$DEV_DIR/sync_config_repos.sh"

printf "\n3) Verify paths\n"
"$DEV_DIR/verify_paths.sh"

printf "\n[Done]\n"
