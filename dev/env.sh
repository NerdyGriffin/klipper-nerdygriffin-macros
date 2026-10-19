#!/usr/bin/env bash
# Shared environment for the dev/ scripts. Source it; do not execute it.
# Part of klipper-nerdygriffin-macros
#
# Host-specific values (peer hostname, SSH target, paths) come from dev/.env,
# which is git-ignored. Copy dev/.env.example to dev/.env on each host.

DEV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$DEV_DIR")"

if [[ -f "$DEV_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "$DEV_DIR/.env"
  set +a
fi

LOCAL_HOST="${LOCAL_HOST:-$(hostname | tr '[:upper:]' '[:lower:]')}"

for required in PEER_HOST PEER_CONFIG_REPO; do
  if [[ -z "${!required:-}" ]]; then
    echo "ERROR: $required is not set. Copy $DEV_DIR/.env.example to $DEV_DIR/.env and edit it." >&2
    return 1 2>/dev/null || exit 1
  fi
done

PEER_SSH="${PEER_SSH:-$PEER_HOST}"

CONFIG_DIR="${CONFIG_DIR:-$HOME/printer_data/config}"
MACROS_DIR="${MACROS_DIR:-$HOME/klipper-nerdygriffin-macros}"
PEER_CONFIG_DIR="${PEER_CONFIG_DIR:-$CONFIG_DIR}"
PEER_MACROS_DIR="${PEER_MACROS_DIR:-$MACROS_DIR}"

# Read-only clone of the peer printer's config repo, kept fresh by sync_peer_config.sh.
PEER_CONFIG_CLONE="${PEER_CONFIG_CLONE:-$HOME/$(basename "$PEER_CONFIG_REPO" .git)}"

export DEV_DIR REPO_DIR LOCAL_HOST PEER_HOST PEER_SSH
export CONFIG_DIR MACROS_DIR PEER_CONFIG_DIR PEER_MACROS_DIR
export PEER_CONFIG_REPO PEER_CONFIG_CLONE

