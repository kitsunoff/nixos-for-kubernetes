#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "CLI кластера — как talosctl, но из flake" \
  "nix run .#cluster-kz-demo -- --help" \
  "plan-help-kz-demo.txt"

step "Порядок converge — просто значение в Nix" \
  "nix eval .#clusterConfigurations.kz-demo.convergeOrder" \
  "plan-convergeOrder-kz-demo.txt"

step "Dry-run: план без изменений на нодах" \
  "nix run .#cluster-kz-demo -- converge --dry-run" \
  "plan-dry-run-kz-demo.txt"
