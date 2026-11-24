#!/usr/bin/env bash
# Push/pull result records and the closing summary for the sync scripts. Sourced by env.sh.
# Part of klipper-nerdygriffin-macros
#
# Records are "status|action|repo|host|detail" lines in $SYNC_RESULTS_FILE. The outermost script
# creates the file and prints the summary on exit; scripts it starts inherit the file. A script run
# on the peer over SSH has no file and prints each record as a "@@result@@|..." line instead, which
# collect_results on the calling side moves into the file.

SYNC_FAILED=0

# result <OK|FAIL|WARN|SKIP> <push|pull> <repo> [detail] [host]
# Self-contained: it is also sent to the peer with `declare -f`.
result() {
  local rec
  rec="$1|$2|$3|${5:-${LOCAL_HOST:-$(hostname | tr '[:upper:]' '[:lower:]')}}|${4:-}"
  if [[ "$1" == FAIL ]]; then
    SYNC_FAILED=1
  fi
  if [[ -n "${SYNC_RESULTS_FILE:-}" ]]; then
    echo "$rec" >>"$SYNC_RESULTS_FILE"
  else
    echo "@@result@@|$rec"
  fi
}

# repo_name <dir>: the repo's name from its origin URL, else the directory name.
# Self-contained: it is also sent to the peer with `declare -f`.
repo_name() {
  local url
  url=$(git -C "$1" remote get-url origin 2>/dev/null || true)
  url=${url%/}
  url=${url%.git}
  if [[ -n "$url" ]]; then
    echo "${url##*[/:]}"
  else
    basename "$1"
  fi
}

# Filter for the stdout of an ssh call: records go to the results file, the rest is passed through.
collect_results() {
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "${SYNC_RESULTS_FILE:-}" && "$line" == '@@result@@|'* ]]; then
      echo "${line#*|}" >>"$SYNC_RESULTS_FILE"
    else
      printf '%s\n' "$line"
    fi
  done
}

# results_count [status]: number of records so far, optionally only those with the given status.
results_count() {
  if [[ -z "${SYNC_RESULTS_FILE:-}" || ! -f "$SYNC_RESULTS_FILE" ]]; then
    echo 0
  elif [[ -n "${1:-}" ]]; then
    grep -c "^$1|" "$SYNC_RESULTS_FILE" || true
  else
    wc -l <"$SYNC_RESULTS_FILE"
  fi
}

results_summary() {
  local rc=$? file=${SYNC_RESULTS_FILE:-}
  trap - EXIT
  if [[ -n "$file" && -s "$file" ]]; then
    local st act repo host detail wr=4 wh=4 ok=0 skip=0 warn=0 fail=0
    while IFS='|' read -r st act repo host detail; do
      if [[ ${#repo} -gt $wr ]]; then wr=${#repo}; fi
      if [[ ${#host} -gt $wh ]]; then wh=${#host}; fi
      case "$st" in
        OK) ok=$((ok + 1)) ;;
        SKIP) skip=$((skip + 1)) ;;
        WARN) warn=$((warn + 1)) ;;
        *) fail=$((fail + 1)) ;;
      esac
    done <"$file"
    printf "\nSummary\n"
    while IFS='|' read -r st act repo host detail; do
      printf '  %-4s  %-4s  %-*s  %-*s  %s\n' "$st" "$act" "$wr" "$repo" "$wh" "$host" "$detail"
    done <"$file"
    echo "$ok ok, $skip skipped, $warn warning(s), $fail failed"
    if [[ $fail -gt 0 && $rc -eq 0 ]]; then
      rc=1
    elif [[ $fail -eq 0 && $rc -ne 0 ]]; then
      echo "Exited with status $rc; see the output above"
    fi
  fi
  if [[ -n "$file" ]]; then
    rm -f "$file"
  fi
  exit "$rc"
}

# Call once near the top of each sync script. Only the outermost one owns the summary.
results_init() {
  if [[ -n "${SYNC_RESULTS_FILE:-}" || -n "${SYNC_RESULTS_STDOUT:-}" ]]; then
    return 0
  fi
  SYNC_RESULTS_FILE=$(mktemp "${TMPDIR:-/tmp}/sync_results.XXXXXX")
  export SYNC_RESULTS_FILE
  trap results_summary EXIT
}
