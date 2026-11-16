#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Секреты в git — только зашифрованные (sops + age)" \
  "cat secrets/kz-demo.yaml" \
  "sops-encrypted.txt"

step "На ноде — расшифрованы sops-nix при активации" \
  "ssh root@192.168.5.3 ls -l /run/secrets/demo" \
  "sops-run-secrets.txt"
