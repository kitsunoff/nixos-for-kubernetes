#!/usr/bin/env bash
# Post-teardown host check for kz-demo; run from demo/ on the builder.
set -u
SSH=(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10)
for pair in kz-node-1=192.168.5.3 kz-node-2=192.168.5.4 kz-node-3=192.168.5.5; do
  m="${pair%%=*}"; ip="${pair#*=}"
  base="$(nix eval --raw ".#clusterConfigurations.kz-demo.teardownNixosConfigurations.$m.config.system.build.toplevel.outPath" 2>/dev/null)"
  echo "=== $m ($ip)"
  "${SSH[@]}" "root@$ip" bash -s "$base" <<'REMOTE'
base="$1"
echo "ssh:             ok ($(hostname))"
echo "current-system:  $(readlink /run/current-system)"
if [ "$(readlink /run/current-system)" = "$base" ]; then echo "                 = teardownNixosConfigurations base"; else echo "                 != base $base"; fi
for u in k3s.service incus.service incus.socket keepalived.service; do
  printf 'unit %-19s %s / %s\n' "$u" "$(systemctl is-active "$u" 2>/dev/null)" "$(systemctl is-enabled "$u" 2>&1 | head -n 1)"
done
for p in /var/lib/rancher /etc/rancher /var/lib/kubelet /var/lib/incus /run/keepalived; do
  if [ -e "$p" ]; then echo "path $p: PRESENT"; else echo "path $p: absent"; fi
done
if [ -e /run/secrets ]; then echo "/run/secrets: $(ls -A /run/secrets | wc -l) entries"; else echo "/run/secrets: absent"; fi
echo "age key kept:    $(test -e /etc/age/key.txt && echo yes || echo no)"
echo "VIP 192.168.5.200:   $(ip -oneline addr | grep -c '192.168.5.200/')"
echo "VIP 192.168.106.200: $(ip -oneline addr | grep -c '192.168.106.200/')"
echo "incusbr links:   $(ip -oneline link show type bridge | grep -c incusbr)"
echo "containers:      $(pgrep -c containerd-shim || true) containerd-shim"
echo "addresses:       $(ip -brief -4 addr show | awk '$1 != "lo" { print $1 "=" $3 }' | tr '\n' ' ')"
REMOTE
done
