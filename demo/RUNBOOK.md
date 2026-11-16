# RUNBOOK — demo VMs, talk day and teardown

Operational guide for the live nixcluster demo (task T7). Facts about the VMs come from
`demo/NODES.md`; the memory plan comes from "Resource budget" in `TASKS.md`. Everything
marked **untested** was not tried on these VMs and needs a check before the talk.

Commands below call `colima`. It is not on `PATH` in every shell; the binary used for the
demo is:

```bash
COLIMA=/nix/store/jqjgkby1k6xm1n24c854cqva6cdq4fwq-colima-0.10.1/bin/colima
```

Replace `colima` with `"$COLIMA"` if `command -v colima` prints nothing.

`ssh`, `ping` and `df` on macOS have no long flag names, so they keep short flags.

## 1. Inventory

### VMs

Read from `colima list` on 2026-11-15. All profiles: `vz`, `aarch64`, runtime `containerd`
(builder: `docker`).

| Profile | Role | CPU | RAM | Disk | `eth0` (VM ↔ VM) | `col0` (Mac ↔ VM) | OS |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `kz-node-1` | `kz-demo` member: k3s server, Incus member, keepalived | 2 | 2 GiB | 20 GiB | 192.168.5.3 | 192.168.106.4 | NixOS |
| `kz-node-2` | `kz-demo` member: k3s server, Incus member, keepalived | 2 | 3 GiB | 20 GiB | 192.168.5.4 | 192.168.106.5 | NixOS |
| `kz-node-3` | `kz-demo` member: k3s server, Incus member, keepalived | 2 | 2 GiB | 20 GiB | 192.168.5.5 | 192.168.106.6 | NixOS |
| `kz-mgmt` | `kz-mgmt` single-node k3s, NIO operator, remote Nix builder | 2 | 3 GiB | 30 GiB | 192.168.5.6 | 192.168.106.7 | NixOS |
| `nix-builder` | control VM: `nix`, `nixos-anywhere`, runs `converge` | 4 | 4 GiB | 60 GiB | 192.168.5.1 | 192.168.106.2 | Ubuntu 24.04 |

1. `kz-node-2` and `kz-mgmt` were raised from the planned 2 / 2.5 GiB to 3 GiB, because
   the nixos-anywhere kexec installer needs about 3 GiB (see [Known issues](#7-known-issues)).
2. The node addresses are static in NixOS (`demo/modules/nodes/*.nix`, pinned by MAC),
   so they survive restarts. Only the builder still gets its addresses over DHCP.
3. `colima list` shows an empty `ADDRESS` column for the NixOS VMs. This is expected:
   Lima's guest agent and cloud-init are gone after the install.
4. Memory in the run phase (builder stopped): 2 + 3 + 2 + 3 = **10 GiB**. With the builder:
   **14 GiB** of 16 GiB. This is more than the 8.5 / 12.5 GiB in the original budget.

### Networks

| Interface | Subnet | Who can reach it |
| --- | --- | --- |
| `eth0` (Lima `user-v2`) | 192.168.5.0/24 | VMs only. Not reachable from the Mac |
| `col0` (vzNAT, `bridge103`) | 192.168.106.0/24 | The Mac only. No VM-to-VM traffic |

### VIPs (keepalived, one VRRP instance on `eth0`)

| VIP | Interface | Use |
| --- | --- | --- |
| 192.168.5.200 | `eth0` | k3s API for nodes and the builder |
| 192.168.106.200 | `col0` | k3s API for `kubectl` from the Mac |

Both VIPs are in the k3s TLS SANs (`demo/modules/clusters/kz-demo.nix`).

### Access

| From | To | How |
| --- | --- | --- |
| Mac | any node | `ssh -i ~/.ssh/nix-builder-colima root@192.168.106.x` |
| Mac | builder | `ssh -i ~/.ssh/nix-builder-colima -p 2222 root@127.0.0.1` |
| builder | any node | `ssh root@192.168.5.x` (builder key `/root/.ssh/id_ed25519`) |

Both public keys are in `users.users.root.openssh.authorizedKeys.keys` in
`demo/modules/base.nix`, so access survives every converge and teardown.

Helper for the Mac (works in zsh and bash). Host keys change on every reinstall, so the
known-hosts file is ignored:

```bash
kzssh() {
  ssh -i "$HOME/.ssh/nix-builder-colima" \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
    "root@$1" "${@:2}"
}
# example: kzssh 192.168.106.4 hostname
```

### Kubeconfigs

| File | `server:` in the file | Reachable from |
| --- | --- | --- |
| `demo/kubeconfig/kz-demo.yaml` | `https://192.168.5.3:6443` | builder only |
| `demo/kubeconfig/kz-mgmt.yaml` | `https://192.168.5.6:6443` | builder only |

From the Mac, override the server with a `col0` address (both are in the TLS SANs):

```bash
kubectl --kubeconfig demo/kubeconfig/kz-demo.yaml --server https://192.168.106.200:6443 get nodes
kubectl --kubeconfig demo/kubeconfig/kz-mgmt.yaml --server https://192.168.106.7:6443 get nodes
```

## 2. Phases

### Provisioning phase (builder running)

Needed only for: first install, `converge` / `teardown` against the VMs, and
`converge --dry-run`. Memory: about 14 GiB, so quit heavy apps first (see
[checklist](#3-before-the-talk-checklist)).

```bash
# the profile stores 4 GiB; pass it explicitly anyway
colima start --profile nix-builder --memory 4

# shell in the builder
ssh -i ~/.ssh/nix-builder-colima -p 2222 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@127.0.0.1

# inside the builder: the repo is mounted at the same path
source /etc/profile
cd /Users/kitsunoff/git/github.com/kitsunoff/nixos-for-kubernetes/demo
nix run .#cluster-kz-demo -- converge --dry-run
```

Side effects of starting the builder (from `NODES.md`):

1. Colima switches the host docker context to `colima-nix-builder`.
2. An old kind container (`go-operator-test-e2e-control-plane`) starts inside the
   builder and takes part of its 4 GiB.
3. If the start fails with `attach disk "colima-nix-builder", in use by instance`, unlock
   the stale disk: `LIMA_HOME=~/.colima/_lima limactl disk unlock colima-nix-builder`.

### Run phase (builder stopped)

The demo, NIO and recordings need only the four node VMs (10 GiB).

```bash
colima stop --profile nix-builder
```

The builder runs Ubuntu with the Lima guest agent, so `colima stop` / `colima start` work
normally for it.

### Stopping and starting the NixOS VMs

After nixos-anywhere replaced Ubuntu on `/dev/vda`, the VM has no Lima guest agent, no
Lima user and no cloud-init. `colima ssh --profile kz-node-N` does not work any more.
**Use `ssh root@192.168.106.x` from the Mac** (helper `kzssh` above).

What is known and what is not:

| Action | Status | Expected behaviour |
| --- | --- | --- |
| `colima ssh --profile kz-node-N` | known: does not work | needs the Lima user and guest agent |
| `colima list` | known: works | shows `Running` / `Stopped`, empty `ADDRESS` |
| `colima stop --profile kz-node-N` | **untested** on NixOS | Lima asks the VM to shut down (vz stop request, NixOS powers off on it); Colima may print errors while it tries to stop the container runtime over SSH |
| `colima stop --force --profile kz-node-N` | **untested** on NixOS | kills the VM process without a clean shutdown; use only if the plain stop hangs |
| `colima start --profile kz-node-N` | **untested** on NixOS | the VM boots NixOS, but Lima waits for its SSH / guest-agent requirements that never come true; the command will likely hang or end with a timeout or "degraded" error while the VM keeps running |

The logs in `~/.colima/_lima/colima-<profile>/ha.stderr.log` show that every start so far
happened while Ubuntu was still on the disk (the VMs were raised to 3 GiB before the
install). No start of an already installed NixOS disk has been recorded yet.

Recommended stop, clean shutdown first (untested as a whole):

```bash
for ip in 192.168.106.4 192.168.106.5 192.168.106.6 192.168.106.7; do
  kzssh "$ip" systemctl poweroff
done
# then let Colima/Lima notice; --force only if the profile still shows Running
colima list
colima stop --profile kz-node-1   # repeat for kz-node-2, kz-node-3, kz-mgmt
```

Recommended start (untested): start each profile and judge success by SSH and
`kubectl`, not by the `colima start` exit code.

```bash
colima start --profile kz-node-1
# if the command hangs on "waiting for the guest agent", keep it running in its own
# terminal tab and check the VM directly:
ping -c 3 192.168.106.4
kzssh 192.168.106.4 systemctl is-system-running
```

**Do this once before the talk day**: stop and start one node (for example `kz-node-3`) and
write down what Colima actually prints. Update this table with the result.

## 3. Before the talk checklist

Do the whole list on the day before and again 1 hour before the talk.

1. **Disk**: at least 10 GiB free on `/`.

   ```bash
   df -h /
   ```

2. **Memory**: pressure level must be `1` (normal). `2` = warning, `4` = critical.

   ```bash
   sysctl kern.memorystatus_vm_pressure_level
   memory_pressure -Q
   ```

   On 2026-11-15, with all five VMs running, the level was `2` (39% free).

3. **Quit heavy apps**: OrbStack (about 2 GiB), Docker Desktop, browsers with many tabs,
   IDEs not needed for the talk. Keep only the slides, the terminal and the presenter view.

4. **Stop the builder** unless you plan to run `converge --dry-run` live:

   ```bash
   colima stop --profile nix-builder
   ```

5. **Start the VMs in order**: the three `kz-demo` members first (etcd needs 2 of 3 for
   quorum), then `kz-mgmt`. Wait for SSH on each before the next one.

   ```bash
   colima start --profile kz-node-1
   colima start --profile kz-node-2
   colima start --profile kz-node-3
   colima start --profile kz-mgmt
   colima list
   ```

6. **Health checks** from the repository root on the Mac:

   ```bash
   # every node answers over col0
   for ip in 192.168.106.4 192.168.106.5 192.168.106.6 192.168.106.7; do
     kzssh "$ip" 'hostname; nixos-version; systemctl is-system-running'
   done

   # VIP for the Mac
   ping -c 3 192.168.106.200

   # Kubernetes: kz-demo (3 nodes Ready) and kz-mgmt (1 node Ready)
   kubectl --kubeconfig demo/kubeconfig/kz-demo.yaml --server https://192.168.106.200:6443 get nodes --output wide
   kubectl --kubeconfig demo/kubeconfig/kz-demo.yaml --server https://192.168.106.200:6443 get pods --all-namespaces
   kubectl --kubeconfig demo/kubeconfig/kz-mgmt.yaml --server https://192.168.106.7:6443 get nodes

   # Incus: all three members ONLINE
   kzssh 192.168.106.4 incus cluster list
   kzssh 192.168.106.4 incus list

   # keepalived: the VIP sits on exactly one node
   for ip in 192.168.106.4 192.168.106.5 192.168.106.6; do
     kzssh "$ip" ip --brief address show col0
   done
   ```

   `incus` is not installed on the Mac, so Incus checks run over SSH.

7. **Playback dry run** in replay mode (no VMs needed), unattended:

   ```bash
   yes '' | DEMO_TYPE_SPEED=0 demo/play/all.sh
   ```

   Then once more interactively, as on stage:

   ```bash
   DEMO_PAUSE_LINES=30 DEMO_CLEAR=1 demo/play/all.sh
   ```

   Check that no step prints `[нет записи: …]` unless it is expected.

8. **Deck**: open the built deck or the exported PDF/PNGs (see [Deck export](#8-deck-export))
   and click through the demo slides once.

## 4. Backup plan: the talk works with zero VMs

| Fallback | Needs | Command |
| --- | --- | --- |
| Slides | nothing | the demo slides contain recorded, trimmed real output |
| Playback, replay mode | nothing | `demo/play/all.sh` (`DEMO_MODE=replay` is the default) |
| Restart playback mid-way | nothing | `DEMO_FROM=05 demo/play/all.sh` |
| `converge --dry-run` | builder VM only | inside the builder: `nix run .#cluster-kz-demo -- converge --dry-run` |
| Converge order | builder VM only | inside the builder: `nix eval .#clusterConfigurations.kz-demo.convergeOrder` |

Decision rule on stage:

1. Any VM, VIP or `kubectl` check fails in the checklist → do not use `DEMO_MODE=live`.
   Use replay mode for the whole talk.
2. Memory pressure is not `1` after quitting apps → stop all demo VMs and use replay mode.
3. `converge --dry-run` only evaluates the flake and prints the plan; it does not touch
   the nodes, so it works even when the node VMs are stopped. Because of T12 item 4 its
   output shows "skipped (dependency … did not succeed)" lines. The recording in
   `demo/output/plan-dry-run-kz-demo.txt` has the same lines.

## 5. After the talk / teardown

### Cluster teardown (optional)

`nixclusterctl <cluster> teardown` removes all cluster state and switches each member back
to base NixOS + SSH. The VMs stay installed and reachable; `converge` brings the cluster
back. It runs from the builder:

```bash
# inside the builder, in demo/
nix run .#cluster-kz-demo -- teardown --dry-run   # plan only
nix run .#cluster-kz-demo -- teardown             # asks for literal "yes"
```

This is not needed to free memory: stopping the VMs is enough.

### Free RAM: stop the VMs

```bash
colima stop --profile nix-builder
colima stop --profile kz-mgmt
colima stop --profile kz-node-3
colima stop --profile kz-node-2
colima stop --profile kz-node-1
colima list
```

See the stop notes in [Phases](#stopping-and-starting-the-nixos-vms): for the NixOS VMs
this path is untested; power off over SSH first if `colima stop` hangs.

### Delete the profiles — user decision only

**DESTRUCTIVE.** These commands delete the VM disks, including the installed NixOS and all
cluster data. They cannot be undone. Run them yourself only when the demo is finished for
good. Nothing in this repository runs them.

```bash
# DESTRUCTIVE — asks for confirmation per profile
colima delete --profile kz-node-1
colima delete --profile kz-node-2
colima delete --profile kz-node-3
colima delete --profile kz-mgmt
```

Keep `nix-builder`: it is the shared Linux builder and is not part of the demo.

The old profiles `node-01` and `node-02` mentioned in `TASKS.md` no longer appear in
`colima list` on 2026-11-15.

## 6. Recovery notes

1. **Host key changed** after a reinstall: use `kzssh` or pass
   `-o UserKnownHostsFile=/dev/null`.
2. **`kubectl` from the Mac times out** with the kubeconfig as is: the file points at
   `192.168.5.x`, which the Mac cannot reach. Add `--server https://192.168.106.200:6443`.
3. **VIP does not answer**: check keepalived on each member
   (`kzssh 192.168.106.4 systemctl status keepalived`) and that at least one member is up.
4. **Colima stuck** on a NixOS profile: `colima stop --force --profile <profile>`
   (untested, unclean shutdown).

## 7. Known issues

The full list of nixcluster bugs found while building the demo, each with its workaround,
is in `TASKS.md`, task **T12**. Two of them matter for operating the VMs:

1. **kexec needs about 3 GiB RAM** (T12 item 14). With 2 GiB the installer fails with
   `kexec_file_load failed: Out of memory`. Before a fresh install on `kz-node-1` or
   `kz-node-3` (2 GiB today), raise the profile to 3 GiB:
   `colima stop --profile kz-node-1 && colima start --profile kz-node-1 --memory 3`.
   A normal `converge` or `teardown` on an installed node does not use kexec and works
   with 2 GiB.
2. **A first install needs a second `converge` run** (T12 item 12). `converge` does not
   wait for a member to come back after the install reboot, so `k3s.kubeconfig` and
   `incus.cluster-join` fail on the first pass. Run `converge` again; the second run takes
   the switch path and completes.

## 8. Deck export

`make png-kz` (and `make pdf-kz`) fails because the installed Playwright expects Chromium
revision `1217` (`node_modules/playwright-core/browsers.json`), while the cache in
`~/Library/Caches/ms-playwright` has only `chromium-1252` and
`chromium_headless_shell-1248` / `-1252`.

Workaround: point slidev at the cached browser through the `EXPORT_FLAGS` hook in the
`Makefile`. The headless shell path has no spaces, so it is the easiest one:

```bash
make png-kz EXPORT_FLAGS="--executable-path $HOME/Library/Caches/ms-playwright/chromium_headless_shell-1252/chrome-headless-shell-mac-arm64/chrome-headless-shell"
make pdf-kz EXPORT_FLAGS="--executable-path $HOME/Library/Caches/ms-playwright/chromium_headless_shell-1252/chrome-headless-shell-mac-arm64/chrome-headless-shell"
```

Alternative, the full Chrome for Testing build (the path has spaces, so it needs inner
single quotes):

```bash
make png-kz EXPORT_FLAGS="--executable-path '$HOME/Library/Caches/ms-playwright/chromium-1252/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing'"
```

Output: `slides-png/kz/` for PNGs, `kz-slides-export.pdf` for the PDF. These commands were
not run while writing this runbook.
