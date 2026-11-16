#!/usr/bin/env bash
# Run every numbered step script (NN-*.sh) in order.
# DEMO_FROM=NN starts from step NN (e.g. DEMO_FROM=05 after a restart on stage).
set -euo pipefail
PLAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$PLAY_DIR/lib.sh"

DEMO_FROM="${DEMO_FROM:-00}"

for script in "$PLAY_DIR"/[0-9][0-9]-*.sh; do
  name="${script##*/}"
  if [ "${name%%-*}" \< "$DEMO_FROM" ]; then
    continue
  fi
  # Sourced, not executed: "q" in any step ends the whole run.
  # shellcheck source=/dev/null
  . "$script"
done

printf '\n'
dim "[конец демо]"
