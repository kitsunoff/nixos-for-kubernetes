#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "keepalived: кто MASTER" \
  "nix run .#cluster-kz-demo -- keepalived status" \
  "vip-status.txt"

step "VIP висит на MASTER" \
  "ssh root@192.168.5.3 ip --brief address show eth0" \
  "vip-addr-master.txt"

step "Failover: гасим keepalived на MASTER" \
  "ssh root@192.168.5.3 systemctl stop keepalived" \
  "vip-failover-stop.txt"

step "VIP переехал на другую ноду" \
  "nix run .#cluster-kz-demo -- keepalived status" \
  "vip-failover-status.txt"

step "API через VIP по-прежнему отвечает" \
  "kubectl --kubeconfig kubeconfig/kz-demo.yaml --server https://192.168.5.200:6443 get nodes" \
  "vip-failover-nodes.txt"

step "Возвращаем keepalived" \
  "ssh root@192.168.5.3 systemctl start keepalived" \
  "vip-failover-restore.txt"
