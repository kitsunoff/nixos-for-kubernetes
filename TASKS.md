# TASKS — live nixcluster demo for the KZ deck

Goal: run a real cluster on the MacBook, bootstrap it with `nixclusterctl`, and put
the real terminal output into the KZ deck (`kz/slides.md`) as proof that the
Kubernetes cluster, the Incus cluster and the rest actually work.

Source of truth for the tool: `~/git/github.com/kitsunoff/nixcluster`
(flake-parts module `nixcluster.<name>`, templates `k3s-ha`, `incus-cluster`,
CLI `nix run .#cluster-<name> -- …` or `nixclusterctl <name> …`).

## Facts found during research

| Topic | Fact | Consequence for the demo |
| --- | --- | --- |
| Host | macOS, Apple Silicon, 16 GiB RAM, 10 CPU | 3 nodes × 3 GiB + builder VM fits, but tight |
| Build host | NixOS closures build only on Linux; `converge` has no `--build-host` | Run `nixclusterctl` from the Colima `nix-builder` VM (`colima-builder-start`) |
| Node VMs | One Colima profile per node, `--vm-type vz --arch aarch64 --network-address` | Nodes are `aarch64-linux`; templates already default to it |
| Install | First run is `nixos-anywhere` and wipes the disk | Only Colima node VMs are targets; never the builder VM |
| Boot | Template `base.nix` uses BIOS GRUB on `/dev/vda1`; Colima vz VMs boot via EFI | Base config must switch to EFI (systemd-boot + disko GPT/ESP). Verify the real disk layout first |
| Incus | No nested KVM under vz | Incus runs system containers only; demo must not launch Incus VMs |
| k3s + Incus | Templates cover them separately (`k3s-ha`, `incus-cluster`) | Demo cluster imports both modules on the same 3 members |
| Converge output | Human log to stderr, one `::nixcluster:result::` JSON line to stdout | Both are good slide material |
| Deck drift | Slides show `nixcluster.lib.mkCluster`, `gen-secrets`, `kubeconfig fetch`; current API is the `nixcluster.<name>` flake module and a `kubeconfig` command | Align slides with the real API (T6) |

## Decisions

1. **Location**: everything lives in `demo/` in this repo.
2. **Topology**: 3 members, each one is a k3s server and an Incus cluster member.
3. **Modules**: `k3s` + `incus` + `sops` + `keepalived` (VIP over unicast peers,
   because VRRP multicast on the Colima vmnet network is not guaranteed).
4. **No live coding on stage**: the deck shows recorded output fragments. In addition,
   a set of bash scripts replays the command flow step by step (T8).

## Tasks

Status legend: `[ ]` todo, `[~]` in progress, `[x]` done.

### T1 — Colima infrastructure `[ ]`

Can run in parallel with T2.

1. Start the control VM: `colima-builder-start`; verify `nix --version` inside it.
2. Create 3 node profiles `kz-node-1..3` (2 CPU, 3 GiB, 20 GiB disk) per the
   `colima-vm` skill.
3. Collect IPs (`colima list --json`), add the builder key to `root` on each node.
4. Record the real boot mode and disk layout of a node (`lsblk`, `ls /sys/firmware/efi`)
   — T2 depends on this.
5. Output: `demo/NODES.md` with profile name, IP, disk device, boot mode.

### T2 — Demo cluster config `[ ]`

Depends on T1 step 4 for the disk/boot facts.

1. `nix flake init --template github:kitsunoff/nixcluster#incus-cluster` into the chosen
   directory, then merge in the k3s module from `k3s-ha`.
2. Cluster `kz-demo`: imports `clusterModules.k3s` + `incus` + `sops` + `keepalived`,
   `incus.cluster.enable = true`, `storageBackend = "dir"`, all members `k3s.role = "server"`,
   one keepalived VIP in the node subnet for the k3s API (added to the k3s TLS SANs).
3. `base.nix`: EFI boot, disko layout for the real disk, DHCP networking,
   builder's public key for root, `nixpkgs.hostPlatform = "aarch64-linux"`.
4. Evaluation checks (no install):
   - `nix eval .#clusterConfigurations.kz-demo.convergeOrder`
   - `nix run .#cluster-kz-demo -- converge --dry-run`
   - build every member's `system.build.toplevel` inside the builder VM.
5. Commit after evaluation passes.

### T3 — Bootstrap with nixclusterctl `[ ]`

Depends on T1 + T2. Destructive for the node VMs only — confirm IPs before running.

1. From the builder VM: `nixclusterctl kz-demo converge` (or `nix run .#cluster-kz-demo -- converge`).
2. Save full stderr and the `::nixcluster:result::` line to `demo/output/converge.log`.
3. Re-run `converge` once more to prove idempotency (expected: switch / skip, no install);
   save as `demo/output/converge-rerun.log`.

### T4 — Proof that everything works `[ ]`

Depends on T3. Save each command's output to `demo/output/<name>.txt`.

1. Kubernetes: `nixclusterctl kz-demo kubeconfig`, then `kubectl get nodes -o wide`,
   `kubectl get pods -A`.
2. Incus: `nixclusterctl kz-demo incus status`, `incus cluster list` (all ONLINE),
   launch one container (`incus launch images:alpine/edge demo`) and `incus list`.
3. sops: `nixclusterctl kz-demo show-secrets` (names only, never values) and the
   decrypted secret paths on a node (`ls -l /run/secrets`).
4. keepalived: `nixclusterctl kz-demo keepalived status`, `ip addr` showing the VIP on
   the master, `kubectl --server https://<VIP>:6443 get nodes`.
5. NixOS: `nixos-version` and `readlink /run/current-system` on each node.
6. Converge plan: `nix eval .#clusterConfigurations.kz-demo.convergeOrder`.
7. Optional: screenshots of the terminal for the deck (`kz/public/`).

### T5 — Demo slides in the KZ deck `[ ]`

Depends on T4.

1. Add 2–4 slides after "Bootstrap новой ноды": config snippet (real `kz-demo` files),
   converge output, `kubectl get nodes`, `incus cluster list`.
2. Use real output only — trimmed, never edited by hand.
3. Rebuild with the existing make targets and check the PDF export.

### T6 — Align existing slides with the real nixcluster API `[ ]`

Independent; can run any time.

1. Slide "Декларативность: весь кластер в одном файле": replace `nixcluster.lib.mkCluster`
   with the `nixcluster.<name>` flake-module form from the README.
2. Slide "Клишкой — как talosctl": check every command against `nixclusterctl kz-demo --help`
   (`gen-secrets` exists only with `sops`; `kubeconfig fetch` → real command name).

### T8 — Scripted command-flow playback `[ ]`

Can be built in wave 1 against placeholder logs; final run uses T4 output.

1. `demo/play/` with numbered scripts (`01-plan.sh`, `02-secrets.sh`, `03-converge.sh`,
   `04-kubernetes.sh`, `05-incus.sh`, `06-vip.sh`, …) and `demo/play/all.sh`.
2. Each step: print a short caption, "type" the command with a typing effect,
   wait for Enter, then print the recorded output from `demo/output/`.
3. Mode switch `DEMO_MODE=replay|live`: `replay` (default) shows recorded output and
   needs no VMs; `live` runs the real command.
4. Pure bash + ANSI colors, no extra dependencies; works in the macOS default terminal.

### T7 — Teardown and backup plan `[ ]`

1. Document how to stop the demo VMs (`colima stop --profile kz-node-N`) to free RAM.
2. Deletion of profiles is done by the user only.
3. Backup for the talk: recorded output + `converge --dry-run` that needs no VMs.

## Parallelization plan for subagents

```text
wave 1:  T1 (infra)  ║  T2 (config, eval only)  ║  T6 (slide API fixes)  ║  T8 (playback scripts)
wave 2:  T3 (bootstrap) → T4 (proof)                 — one agent, sequential
wave 3:  T5 (demo slides)  ║  T7 (teardown doc)  ║  T8 final pass on real logs
```

Wave 2 is one agent on purpose: converge and verification share live VM state.
