#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Забираем kubeconfig" \
  "nix run .#cluster-kz-demo -- k3s kubeconfig fetch" \
  "k8s-kubeconfig.txt"

step "Три ноды k3s, все server" \
  "kubectl --kubeconfig kubeconfig/kz-demo.yaml get nodes --output wide" \
  "k8s-nodes.txt"

step "Системные поды" \
  "kubectl --kubeconfig kubeconfig/kz-demo.yaml get pods --all-namespaces" \
  "k8s-pods.txt"

step "API через VIP keepalived" \
  "kubectl --kubeconfig kubeconfig/kz-demo.yaml --server https://192.168.5.200:6443 get nodes" \
  "k8s-nodes-vip.txt"
