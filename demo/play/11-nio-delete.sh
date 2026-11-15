#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "NIO: удаляем NixCluster — оператор делает teardown" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml delete nixcluster kz-demo --wait=false" \
  "nio-delete.txt"

step "Finalizer держит объект: converge остановлен, идёт teardown-джоба" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixcluster,nixcronjobs,nixjobs,jobs" \
  "nio-delete-status.txt"

step "Логи teardown-джобы" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml logs --follow job/kz-demo-teardown-r-5523d26b33a2 --container app" \
  "nio-teardown-logs.txt"

step "Finalizer снят, ресурсов больше нет" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixclusters,nixcronjobs,nixjobs,jobs" \
  "nio-delete-after.txt"

step "На нодах кластера больше нет" \
  "ssh root@192.168.5.3 'systemctl is-active k3s incus keepalived; ls /var/lib/rancher /var/lib/incus'" \
  "nio-delete-nodes.txt"
