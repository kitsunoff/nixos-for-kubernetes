#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Teardown: как terraform destroy для всего кластера" \
  "nix run .#cluster-kz-demo -- teardown --auto-approve" \
  "teardown.log" wip
