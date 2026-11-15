#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "NIO: удаляем NixCluster — оператор делает teardown" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml delete nixcluster kz-demo" \
  "nio-delete.txt" wip

step "Finalizer снят, ресурса больше нет" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixclusters" \
  "nio-delete-after.txt" wip
