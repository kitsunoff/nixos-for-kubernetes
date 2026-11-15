#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "NIO: Machine, NixBuilder и NixCluster как k8s-ресурсы" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml apply --server-side --filename nio/" \
  "nio-apply.txt" wip
