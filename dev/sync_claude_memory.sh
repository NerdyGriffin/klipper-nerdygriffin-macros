#!/usr/bin/env bash
# Replicate Claude Code project memory between this host and the peer with git.
# Part of klipper-nerdygriffin-macros
#
# Each ~/.claude/projects/<slug>/memory directory gets a detached git dir at
# $MEMORY_SYNC_DIR/<slug>.git. The script commits local changes, then fetches
# and merges the peer's repo over SSH. Nobody pushes: the peer merges us on its
# own run, so both hosts converge within two cycles. MEMORY.md merges by line
# union; any other conflicting file resolves in the peer's favour, with the local
# version kept in history.
#
# Usage: sync_claude_memory.sh [--quiet] [--status] [--install-cron]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
MEMORY_SYNC_DIR="${MEMORY_SYNC_DIR:-$CLAUDE_DIR/memory-sync}"
PEER_MEMORY_SYNC_DIR="${PEER_MEMORY_SYNC_DIR:-$MEMORY_SYNC_DIR}"
LOG_FILE="$MEMORY_SYNC_DIR/sync.log"
LOG_KEEP=500
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5)
SCRIPT_PATH="$(readlink -f "$0")"

QUIET=0
MODE=sync
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    --status) MODE=status ;;
    --install-cron) MODE=install-cron ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

mkdir -p "$MEMORY_SYNC_DIR"

log() {
  local line
  line="$(date -Is) [$LOCAL_HOST] $*"
  echo "$line" >>"$LOG_FILE"
  [[ $QUIET -eq 1 ]] || echo "$line"
}

trim_log() {
  if [[ -f "$LOG_FILE" ]] && [[ $(wc -l <"$LOG_FILE") -gt $LOG_KEEP ]]; then
    tail -n "$LOG_KEEP" "$LOG_FILE" >"$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
  fi
}

# g <gitdir> <worktree> <git args...>
g() {
  local gitdir=$1 worktree=$2
  shift 2
  git --git-dir="$gitdir" --work-tree="$worktree" "$@"
}

init_repo() {
  local gitdir=$1 memdir=$2
  [[ -d "$gitdir" ]] && return 0
  log "init $gitdir"
  g "$gitdir" "$memdir" init -q -b main
  g "$gitdir" "$memdir" config core.worktree "$memdir"
  g "$gitdir" "$memdir" config user.name "$LOCAL_HOST"
  g "$gitdir" "$memdir" config user.email "$USER@$LOCAL_HOST"
  mkdir -p "$gitdir/info"
  echo "MEMORY.md merge=union" >"$gitdir/info/attributes"
}

commit_local() {
  local gitdir=$1 memdir=$2
  g "$gitdir" "$memdir" add -A
  if [[ -n "$(g "$gitdir" "$memdir" status --porcelain)" ]]; then
    g "$gitdir" "$memdir" commit -q -m "memory: $LOCAL_HOST $(date -Is)"
    log "committed local changes in $(basename "$(dirname "$memdir")")"
  fi
}

# Drop exact duplicate index lines that a union merge can leave behind.
dedupe_index() {
  local gitdir=$1 memdir=$2 index="$memdir/MEMORY.md"
  [[ -f "$index" ]] || return 0
  awk '/^[[:space:]]*$/ || !seen[$0]++' "$index" >"$index.tmp"
  if cmp -s "$index" "$index.tmp"; then
    rm -f "$index.tmp"
  else
    mv "$index.tmp" "$index"
    g "$gitdir" "$memdir" add -A
    g "$gitdir" "$memdir" commit -q -m "memory: dedupe MEMORY.md after merge"
    log "deduplicated MEMORY.md"
  fi
}

merge_peer() {
  local gitdir=$1 memdir=$2 slug=$3
  local url="ssh://$PEER_SSH$PEER_MEMORY_SYNC_DIR/$slug.git"

  if ! ssh "${SSH_OPTS[@]}" "$PEER_SSH" test -d "$PEER_MEMORY_SYNC_DIR/$slug.git" 2>/dev/null; then
    log "peer $PEER_SSH unreachable or has no repo for $slug; skipping merge"
    return 0
  fi

  g "$gitdir" "$memdir" remote set-url peer "$url" 2>/dev/null \
    || g "$gitdir" "$memdir" remote add peer "$url"
  if ! g "$gitdir" "$memdir" fetch -q peer main 2>>"$LOG_FILE"; then
    log "fetch from $url failed"
    return 0
  fi

  if ! g "$gitdir" "$memdir" rev-parse -q --verify HEAD >/dev/null; then
    g "$gitdir" "$memdir" reset -q --hard peer/main
    log "bootstrapped $slug from peer ($(g "$gitdir" "$memdir" rev-parse --short HEAD))"
    return 0
  fi

  local before after
  before=$(g "$gitdir" "$memdir" rev-parse HEAD)
  if g "$gitdir" "$memdir" merge-base HEAD peer/main >/dev/null 2>&1; then
    merge_args=()
  else
    merge_args=(--allow-unrelated-histories)
  fi

  if ! g "$gitdir" "$memdir" merge -q --no-edit -X theirs "${merge_args[@]}" peer/main >>"$LOG_FILE" 2>&1; then
    # Content conflicts are already resolved by -X theirs; what remains is
    # modify/delete or add/add. Take the peer's side, or delete if it deleted.
    local path
    while IFS= read -r path; do
      [[ -n "$path" ]] || continue
      if g "$gitdir" "$memdir" checkout --theirs -- "$path" 2>/dev/null; then
        g "$gitdir" "$memdir" add -- "$path"
      else
        g "$gitdir" "$memdir" rm -q -- "$path"
      fi
      log "conflict on $path resolved in favour of peer (local version in history)"
    done < <(g "$gitdir" "$memdir" diff --name-only --diff-filter=U)
    g "$gitdir" "$memdir" commit -q --no-edit
  fi

  after=$(g "$gitdir" "$memdir" rev-parse HEAD)
  if [[ "$before" != "$after" ]]; then
    log "merged peer into $slug ($(echo "$before" | head -c 7) -> $(echo "$after" | head -c 7))"
    dedupe_index "$gitdir" "$memdir"
  fi
}

sync_one() {
  local memdir=$1
  local slug gitdir
  slug="$(basename "$(dirname "$memdir")")"
  gitdir="$MEMORY_SYNC_DIR/$slug.git"

  init_repo "$gitdir" "$memdir"
  if [[ -f "$gitdir/MERGE_HEAD" ]]; then
    log "aborting stale merge in $slug"
    g "$gitdir" "$memdir" merge --abort || true
  fi
  commit_local "$gitdir" "$memdir"
  merge_peer "$gitdir" "$memdir" "$slug"
  commit_local "$gitdir" "$memdir"
}

do_sync() {
  exec 9>"$MEMORY_SYNC_DIR/.lock"
  if ! flock -n 9; then
    log "another sync is running; exiting"
    exit 0
  fi
  local found=0 memdir
  for memdir in "$CLAUDE_DIR"/projects/*/memory; do
    [[ -d "$memdir" ]] || continue
    found=1
    sync_one "$memdir"
  done
  [[ $found -eq 1 ]] || log "no memory directories under $CLAUDE_DIR/projects"
  trim_log
}

do_status() {
  echo "[sync_claude_memory] Host: $LOCAL_HOST  Peer: $PEER_SSH"
  echo "Sync dir: $MEMORY_SYNC_DIR"
  local memdir slug gitdir
  for memdir in "$CLAUDE_DIR"/projects/*/memory; do
    [[ -d "$memdir" ]] || continue
    slug="$(basename "$(dirname "$memdir")")"
    gitdir="$MEMORY_SYNC_DIR/$slug.git"
    printf "\n--- %s\n" "$slug"
    if [[ -d "$gitdir" ]]; then
      g "$gitdir" "$memdir" log --oneline -5 2>/dev/null || echo "(no commits yet)"
      local dirty
      dirty=$(g "$gitdir" "$memdir" status --porcelain)
      [[ -z "$dirty" ]] && echo "clean" || printf "uncommitted:\n%s\n" "$dirty"
    else
      echo "not initialised (run without --status)"
    fi
  done
  printf "\nRecent log:\n"
  [[ -f "$LOG_FILE" ]] && tail -n 10 "$LOG_FILE" || echo "(no log yet)"
  echo
  crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" || echo "cron: not installed (use --install-cron)"
}

do_install_cron() {
  local line="*/5 * * * * $SCRIPT_PATH --quiet"
  { crontab -l 2>/dev/null | grep -F -v "$SCRIPT_PATH" || true; echo "$line"; } | crontab -
  echo "Installed crontab entry on $LOCAL_HOST:"
  echo "  $line"
}

case "$MODE" in
  sync) do_sync ;;
  status) do_status ;;
  install-cron) do_install_cron ;;
esac
