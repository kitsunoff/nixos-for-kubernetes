#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Incus: статус на всех нодах" \
  "nix run .#cluster-kz-demo -- incus status" \
  "incus-status.txt"

step "Incus-кластер из тех же трёх нод" \
  "ssh root@192.168.5.3 incus cluster list" \
  "incus-cluster-list.txt"

step "Запускаем контейнер" \
  "ssh root@192.168.5.3 incus launch images:alpine/edge demo" \
  "incus-launch.txt"

step "Инстансы по нодам" \
  "nix run .#cluster-kz-demo -- incus list" \
  "incus-list.txt"
