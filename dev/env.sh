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

if [[ -z "${PEER_HOST:-}" ]]; then
  echo "ERROR: PEER_HOST is not set. Copy $DEV_DIR/.env.example to $DEV_DIR/.env and edit it." >&2
  return 1 2>/dev/null || exit 1
fi

PEER_SSH="${PEER_SSH:-$PEER_HOST}"
PEER_EXPORT_CLIENT="${PEER_EXPORT_CLIENT:-$PEER_HOST}"

CONFIG_DIR="${CONFIG_DIR:-$HOME/printer_data/config}"
MACROS_DIR="${MACROS_DIR:-$HOME/klipper-nerdygriffin-macros}"
PEER_CONFIG_DIR="${PEER_CONFIG_DIR:-$CONFIG_DIR}"
PEER_MACROS_DIR="${PEER_MACROS_DIR:-$MACROS_DIR}"

MOUNT_ROOT="${MOUNT_ROOT:-/mnt}"
PEER_MOUNT="${PEER_MOUNT:-$MOUNT_ROOT/$PEER_HOST/printer_data/config}"

NFS_MOUNT_OPTS="${NFS_MOUNT_OPTS:-defaults,nofail,soft,timeo=14,_netdev,x-systemd.automount}"
NFS_EXPORT_OPTS="${NFS_EXPORT_OPTS:-rw,sync,no_subtree_check,fsid=0}"

export DEV_DIR REPO_DIR LOCAL_HOST PEER_HOST PEER_SSH PEER_EXPORT_CLIENT
export CONFIG_DIR MACROS_DIR PEER_CONFIG_DIR PEER_MACROS_DIR
export MOUNT_ROOT PEER_MOUNT NFS_MOUNT_OPTS NFS_EXPORT_OPTS

# Print TARGET SOURCE OPTIONS for every NFS mount under the given directory.
nfs_mounts_under() {
  findmnt -t nfs,nfs4 -l -n -o TARGET,SOURCE,OPTIONS 2>/dev/null \
    | awk -v root="${1%/}/" 'index($1, root) == 1'
}
