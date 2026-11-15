#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "NIO: статус машин, кластера и converge-джобы" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get machines,nixclusters,nixcronjobs,jobs" \
  "nio-status.txt"

step "Оператор раскатал всех участников" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixcluster kz-demo --output jsonpath=\"{range .status.nodeGroups[*].members[*]}{.name}{\\\"\\t\\\"}{.status}{\\\"\\n\\\"}{end}\"" \
  "nio-cluster-members.txt"

step "Логи converge-джобы, которую создал оператор" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml logs job/kz-demo-converge-r-26e34252e4eb-manual --container app" \
  "nio-converge-logs.txt"

step "Коммит в репозиторий кластера" \
  "git --no-pager diff" \
  "nio-commit-diff.txt" wip

step "git push" \
  "git commit --all --message \"kz-demo: set a motd\" && git push origin main" \
  "nio-commit-rollout.txt" wip

step "Оператор увидел новый коммит и запустил converge" \
  "kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixcronjob,jobs" \
  "nio-rollout-jobs.txt"

step "Раскатилось само" \
  "ssh root@192.168.5.3 'grep --only-matching \"motd=[^ ]*\" /etc/pam.d/sshd | cut --delimiter== --fields=2 | xargs cat; echo'" \
  "nio-rollout-motd.txt"
