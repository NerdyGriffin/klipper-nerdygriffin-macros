#!/usr/bin/env bash
# Daily, non-clobbering git sync of the local clones: the peer config clone, the
# macros repo, the KlipperScreen add-on repo, and the printer config. Part of klipper-nerdygriffin-macros
#
# Each repo is fetched and fast-forwarded from its upstream; commits already
# ahead of origin are pushed (never for the read-only peer config clone).
# Nothing is ever auto-committed, stashed, reset, or rebased: a fast-forward
# that would touch an uncommitted edit is refused by git and logged, and an
# in-progress merge/rebase, a detached HEAD, or diverged history is skipped.
# Each host runs its own copy; the clones meet at GitHub, so no SSH to the peer.
#
# Usage: sync_local_repos.sh [--quiet] [--status] [--install-cron]
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

SYNC_LOCAL_REPOS_DIR="${SYNC_LOCAL_REPOS_DIR:-$HOME/.local/state/nerdygriffin-macros}"
LOG_FILE="$SYNC_LOCAL_REPOS_DIR/sync_local_repos.log"
LOG_KEEP=500
GIT_TIMEOUT=120
SCRIPT_PATH="$(readlink -f "$0")"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=10"

QUIET=0
MODE=sync
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=1 ;;
    --status) MODE=status ;;
    --install-cron) MODE=install-cron ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

mkdir -p "$SYNC_LOCAL_REPOS_DIR"

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

# Repos to sync: "<path>|<push 0/1>". The peer config clone is a read-only reference.
REPOS=(
  "$PEER_CONFIG_CLONE|0"
  "$MACROS_DIR|1"
  "$ADDON_DIR|1"
  "$CONFIG_DIR|1"
)

in_progress() {
  local gitdir
  gitdir=$(git -C "$1" rev-parse --absolute-git-dir)
  [[ -e "$gitdir/MERGE_HEAD" || -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" \
     || -e "$gitdir/CHERRY_PICK_HEAD" ]]
}

dirty_count() {
  git -C "$1" status --porcelain --untracked-files=no | wc -l
}

# sync_one <dir> <push 0|1>. Every failure logs and returns 0 so later repos still run.
sync_one() {
  local dir=$1 push=$2 name
  name=$(basename "$dir")

  if [[ ! -d "$dir/.git" ]]; then
    log "$name: not a git repo at $dir; skipping"
    return 0
  fi
  if in_progress "$dir"; then
    log "$name: merge/rebase/cherry-pick in progress; skipping"
    return 0
  fi
  local branch upstream
  branch=$(git -C "$dir" symbolic-ref -q --short HEAD || true)
  if [[ -z "$branch" ]]; then
    log "$name: detached HEAD; skipping"
    return 0
  fi
  if ! git -C "$dir" rev-parse -q --verify '@{u}' >/dev/null 2>&1; then
    log "$name: branch $branch has no upstream; skipping"
    return 0
  fi
  upstream=$(git -C "$dir" rev-parse --abbrev-ref '@{u}')

  local err
  if ! err=$(timeout "$GIT_TIMEOUT" git -C "$dir" fetch -q origin 2>&1); then
    log "$name: fetch failed (offline?): ${err:-timeout}"
    return 0
  fi

  local behind ahead before after counts
  if ! counts=$(git -C "$dir" rev-list --left-right --count '@{u}...HEAD' 2>&1); then
    log "$name: cannot compare with $upstream: $counts"
    return 0
  fi
  read -r behind ahead <<<"$counts"
  before=$(git -C "$dir" rev-parse --short HEAD)

  if [[ "$behind" -gt 0 && "$ahead" -gt 0 ]]; then
    log "$name: $branch has diverged from $upstream ($ahead ahead, $behind behind); needs manual attention"
    return 0
  fi

  if [[ "$behind" -gt 0 ]]; then
    if err=$(git -C "$dir" merge -q --ff-only '@{u}' 2>&1); then
      after=$(git -C "$dir" rev-parse --short HEAD)
      log "$name: fast-forwarded $before -> $after ($behind commit(s))"
    else
      log "$name: fast-forward refused ($(echo "$err" | grep -v '^$' | head -n 1)); local work preserved"
      return 0
    fi
  fi

  if [[ "$ahead" -gt 0 ]]; then
    if [[ "$push" -eq 1 ]]; then
      if err=$(timeout "$GIT_TIMEOUT" git -C "$dir" push -q 2>&1); then
        log "$name: pushed $ahead commit(s) to $upstream"
      else
        log "$name: push failed: ${err:-timeout}"
      fi
    else
      log "$name: $ahead local commit(s) ahead of $upstream, not pushed (read-only reference)"
    fi
  fi

  local dirty
  dirty=$(dirty_count "$dir")
  if [[ "$dirty" -gt 0 ]]; then
    if [[ "$push" -eq 1 ]]; then
      log "$name: $dirty uncommitted path(s) left untouched"
    else
      log "$name: $dirty uncommitted path(s) in a read-only reference clone; edit on the peer host and push"
    fi
  fi

  if [[ "$behind" -eq 0 && "$ahead" -eq 0 ]]; then
    log "$name: up to date ($before)"
  fi
}

do_sync() {
  exec 9>"$SYNC_LOCAL_REPOS_DIR/.sync_local_repos.lock"
  if ! flock -n 9; then
    log "another sync is running; exiting"
    exit 0
  fi
  local entry
  for entry in "${REPOS[@]}"; do
    sync_one "${entry%|*}" "${entry#*|}"
  done
  trim_log
}

do_status() {
  echo "[sync_local_repos] Host: $LOCAL_HOST"
  echo "State dir: $SYNC_LOCAL_REPOS_DIR"
  local entry dir branch behind ahead counts
  for entry in "${REPOS[@]}"; do
    dir=${entry%|*}
    printf "\n--- %s (%s)\n" "$(basename "$dir")" "$([[ ${entry#*|} -eq 1 ]] && echo push || echo pull-only)"
    if [[ ! -d "$dir/.git" ]]; then
      echo "MISSING  $dir"
      continue
    fi
    branch=$(git -C "$dir" symbolic-ref -q --short HEAD || echo "(detached)")
    if counts=$(git -C "$dir" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
      read -r behind ahead <<<"$counts"
      echo "$branch: $ahead ahead, $behind behind (as of last fetch)"
    else
      echo "$branch: no upstream"
    fi
    git -C "$dir" log -1 --format='%h %ad %s' --date=short
    local dirty
    dirty=$(dirty_count "$dir")
    [[ "$dirty" -eq 0 ]] && echo "clean" || echo "uncommitted: $dirty path(s)"
    in_progress "$dir" && echo "WARN  merge/rebase in progress"
  done
  printf "\nRecent log:\n"
  [[ -f "$LOG_FILE" ]] && tail -n 10 "$LOG_FILE" || echo "(no log yet)"
  echo
  crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" || echo "cron: not installed (use --install-cron)"
}

do_install_cron() {
  local line="30 4 * * * $SCRIPT_PATH --quiet"
  { crontab -l 2>/dev/null | grep -F -v "$SCRIPT_PATH" || true; echo "$line"; } | crontab -
  echo "Installed crontab entry on $LOCAL_HOST:"
  echo "  $line"
}

case "$MODE" in
  sync) do_sync ;;
  status) do_status ;;
  install-cron) do_install_cron ;;
esac
