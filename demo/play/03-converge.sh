#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Converge: установка NixOS + k3s + Incus + sops + keepalived" \
  "nix run .#cluster-kz-demo -- converge --age-key-file secrets/kz-demo.age.key" \
  "converge.log"
