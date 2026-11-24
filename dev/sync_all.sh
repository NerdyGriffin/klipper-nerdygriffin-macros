#!/usr/bin/env bash
# Sync the macros and KlipperScreen add-on repos, then the config repos and peer config clones, on both
# hosts, then verify. The branch argument applies to the macros repo only. Every step runs even if
# an earlier one failed; a summary of each push and pull is printed last.
# Part of klipper-nerdygriffin-macros
#
# Usage: sync_all.sh [branch]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

BRANCH_ARG=${1:-}

results_init
failed=0

printf "[sync_all] Host: %s\n" "$LOCAL_HOST"

printf "\n1) Sync macros and KlipperScreen add-on repos on both hosts\n"
"$DEV_DIR/sync_macros_repo.sh" ${BRANCH_ARG:+"$BRANCH_ARG"} || failed=1

printf "\n2) Sync config repos and peer config clones on both hosts\n"
"$DEV_DIR/sync_config_repos.sh" || failed=1

printf "\n3) Verify paths\n"
"$DEV_DIR/verify_paths.sh" || failed=1

printf "\n[Done]\n"
exit "$failed"
