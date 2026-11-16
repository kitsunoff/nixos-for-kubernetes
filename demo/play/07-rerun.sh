#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Повторный converge — идемпотентно: switch/skip, без переустановки" \
  "nix run .#cluster-kz-demo -- converge --age-key-file secrets/kz-demo.age.key" \
  "converge-rerun.log"
