#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "NIO: статус машин и кластера" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get machines,nixclusters" \
  "nio-status.txt" wip
