#!/usr/bin/env bash
# Shared helpers for the demo playback scripts (demo/play/NN-*.sh).
#
# A step script sources this file and calls `step` once per command:
#
#   step "<caption>" "<command>" "<output file in demo/output>" [wip]
#
# Bash 3.2 compatible (macOS default): no associative arrays, no ${var,,}.

# Sourced by every step script and by all.sh; define everything only once.
if [ -n "${DEMO_LIB_LOADED:-}" ]; then
  return 0
fi
DEMO_LIB_LOADED=1

PLAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(cd "$PLAY_DIR/.." && pwd)"

DEMO_MODE="${DEMO_MODE:-replay}"
DEMO_TYPE_SPEED="${DEMO_TYPE_SPEED:-0.03}"
DEMO_PAUSE_LINES="${DEMO_PAUSE_LINES:-0}"
DEMO_CLEAR="${DEMO_CLEAR:-0}"
DEMO_OUTPUT_DIR="${DEMO_OUTPUT_DIR:-$DEMO_DIR/output}"
DEMO_KEEP_WARNINGS="${DEMO_KEEP_WARNINGS:-0}"

case "$DEMO_MODE" in
  replay | live) ;;
  *)
    echo "DEMO_MODE must be 'replay' or 'live', got '$DEMO_MODE'" >&2
    exit 2
    ;;
esac

if [ -n "${NO_COLOR:-}" ]; then
  C_RESET='' C_DIM='' C_CAPTION='' C_PROMPT='' C_CMD='' C_WARN=''
else
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_CAPTION=$'\033[1;36m'
  C_PROMPT=$'\033[1;32m'
  C_CMD=$'\033[1;37m'
  C_WARN=$'\033[33m'
fi

# Print a dim one-line marker.
dim() {
  printf '%s%s%s\n' "$C_DIM" "$*" "$C_RESET"
}

# Read one key from stdin into DEMO_KEY: "" (Enter), "s", "q", ...
# End of input counts as Enter so piped runs never hang.
read_key() {
  DEMO_KEY=""
  IFS= read -r -s -n 1 DEMO_KEY || DEMO_KEY=""
}

quit_demo() {
  printf '\n'
  dim "[выход]"
  exit 0
}

# "Type" a command after the prompt, one character at a time.
type_command() {
  local cmd="$1" i=0
  printf '%s$%s %s' "$C_PROMPT" "$C_RESET" "$C_CMD"
  while [ "$i" -lt "${#cmd}" ]; do
    printf '%s' "${cmd:$i:1}"
    if [ "$DEMO_TYPE_SPEED" != "0" ]; then
      sleep "$DEMO_TYPE_SPEED"
    fi
    i=$((i + 1))
  done
  printf '%s' "$C_RESET"
}

# Recording without the leading "$ command" line, the trailing "[exit N]"
# line and (unless DEMO_KEEP_WARNINGS=1) nix's dirty-tree warnings.
recording_body() {
  local drop_warnings='/^warning: Git tree .* is dirty$/d'
  if [ "$DEMO_KEEP_WARNINGS" = "1" ]; then
    drop_warnings=''
  fi
  sed -e '1{/^\$ /d;}' -e '${/^\[exit [0-9]*\]$/d;}' -e "$drop_warnings" "$1"
}

# Print a recording, pausing every DEMO_PAUSE_LINES lines.
replay_output() {
  local file="$DEMO_OUTPUT_DIR/$1" line n=0
  if [ ! -f "$file" ]; then
    dim "[нет записи: $1]"
    return 0
  fi
  while IFS= read -r line <&3 || [ -n "$line" ]; do
    printf '%s\n' "$line"
    n=$((n + 1))
    if [ "$DEMO_PAUSE_LINES" -gt 0 ] && [ $((n % DEMO_PAUSE_LINES)) -eq 0 ]; then
      printf '%s-- ещё: Enter, s = пропустить, q = выход --%s' "$C_DIM" "$C_RESET"
      read_key
      printf '\r\033[K'
      case "$DEMO_KEY" in
        s | S) dim "[вывод пропущен]"; break ;;
        q | Q) exec 3<&-; quit_demo ;;
      esac
    fi
  done 3< <(recording_body "$file")
  exec 3<&-
}

# Run the real command from demo/. KUBECONFIG points into demo/kubeconfig/
# so even a kubectl call without --kubeconfig never reads ~/.kube/config.
live_output() {
  local cmd="$1" rc=0
  (
    cd "$DEMO_DIR"
    KUBECONFIG="$DEMO_DIR/kubeconfig/kz-demo.yaml" bash -c "$cmd"
  ) || rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '%s[exit %s]%s\n' "$C_WARN" "$rc" "$C_RESET"
  fi
}

# step "<caption>" "<command>" "<output file>" [wip]
#   wip: the feature is not ready yet; live mode does not run the command.
step() {
  local caption="$1" cmd="$2" file="$3" wip="${4:-}"
  local script="${BASH_SOURCE[1]##*/}"
  local num="${script%%-*}"

  if [ "$DEMO_CLEAR" = "1" ]; then
    printf '\033[H\033[2J'
  fi
  printf '\n%s[%s] %s%s' "$C_CAPTION" "$num" "$caption" "$C_RESET"
  if [ -n "$wip" ]; then
    printf ' %s[в разработке]%s' "$C_WARN" "$C_RESET"
  fi
  printf '\n'

  type_command "$cmd"
  read_key
  printf '\n'
  case "$DEMO_KEY" in
    s | S) dim "[вывод пропущен]"; return 0 ;;
    q | Q) quit_demo ;;
  esac

  if [ "$DEMO_MODE" = "replay" ]; then
    replay_output "$file"
  elif [ -n "$wip" ]; then
    dim "[в разработке: команда не запускается в live-режиме]"
  else
    live_output "$cmd"
  fi
}
