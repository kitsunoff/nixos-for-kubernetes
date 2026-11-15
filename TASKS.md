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

### T9 — `teardown` command in nixcluster (full cluster teardown) `[ ]`

Lives in `~/git/github.com/kitsunoff/nixcluster`, not in this repo: own feature
branch from `master` (`feat/teardown`), own PR. Independent of T1–T8; the demo uses it
in T4/T8 as the final step once it is merged or available on the branch.

Current state (checked on `master`, all branches, worktrees, stash): there is no
whole-cluster teardown. Only per-member prune exists (`lib/prune.nix`), and it
deliberately refuses an empty desired set, so it cannot be used to dissolve a cluster.

Semantics: like `terraform destroy`. `teardown` removes everything the cluster
definition created; `converge` is the inverse and recreates all of it from the
same definition. `teardown` → `converge` must give the same cluster again.

Proposed design:

1. New core command `nixclusterctl <cluster> teardown [--dry-run] [--json] [--auto-approve]`.
2. Terraform-style flow: compute and print the destroy plan (every member, every
   module step, in order), then ask `Enter a value:` and proceed only on the literal
   `yes`. `--auto-approve` skips the prompt; `--dry-run` prints the plan and exits.
3. End state of every member: all cluster state removed and the host switched back to
   `defaultNixosConfiguration` (base NixOS + SSH, no cluster modules). The host stays
   reachable, so the next `converge` takes the normal switch path and rebuilds the
   cluster. Disk wipe is NOT part of teardown: a wiped host has no SSH, and converge
   could not reach it without PXE.
4. Modules contribute `teardown.steps` the same way they contribute `converge.steps`;
   `lib/convergePlan.nix` sorts them. Order is the reverse of converge:
   1. workloads off: Incus instances stopped/removed, k3s drained;
   2. joiners leave first: k3s agents, then non-bootstrap servers, then Incus joiners;
   3. bootstrap member last;
   4. per-module cleanup on each host: k3s data (`/var/lib/rancher`, `/etc/rancher`),
      Incus cluster state, keepalived/nebula stopped, sops secrets removed from `/run/secrets`;
   5. switch each member to `defaultNixosConfiguration`.
5. Unreachable members are reported in the result, not fatal.
6. Same output contract as converge: human log on stderr, one
   `::nixcluster:result::` JSON line on stdout with per-member `action: "destroyed"`.
7. Tests first (TDD): extend the stub approach of `scripts/check-prune.sh` with a
   `scripts/check-teardown.sh` — plan order per template, refusal on anything but `yes`,
   `--dry-run` touches nothing, unreachable host path, and a round-trip check that the
   teardown plan is the reverse of the converge plan. Add it to CI next to the others.
8. README: new "Teardown" section and CLI entry.
9. Live check on the demo VMs: `converge` → `teardown --auto-approve` → `converge`,
   the second converge must bring both clusters back.

### T10 — NIO: teardown on `NixCluster` deletion `[ ]`

Lives in `~/git/github.com/kitsunoff/NIO`: own branch from `main`
(`feat/nixcluster-teardown`), own PR. Depends on T9 (`nixclusterctl teardown` must exist).
NIO uses OpenSpec: start with an `openspec/changes/nixcluster-teardown/` proposal and
a delta to `openspec/specs/cluster-convergence`.

Current state: `reconcileRemoving` in `internal/controller/nixcluster_controller.go`
deletes the converge `NixCronJob` and removes the finalizer. The comment says
"Node teardown / decommission is deferred". Deleting a `NixCluster` leaves the real
k3s/Incus clusters running on the machines.

Proposed design:

1. New field `spec.deletionPolicy`: `Teardown` (default) or `Retain` (today's behaviour,
   only the Kubernetes objects go away).
2. On deletion with `Teardown`, the finalizer stays until teardown finishes:
   1. suspend the converge `NixCronJob` and wait for an active converge run to end;
   2. create one owned `NixJob` `<cluster>-teardown` with the converge pod template
      (same SSH key, builder, flake source) and args `teardown --auto-approve --json`;
   3. parse the `::nixcluster:result::` line into status (per-member result);
   4. success → delete the converge cron, remove the finalizer;
   5. failure → keep the finalizer, condition `TeardownFailed` with the message,
      retry with backoff. Escape hatch: changing `deletionPolicy` to `Retain` on the
      object being deleted lets the finalizer go without teardown.
3. Phase `Terminating` / condition `TearingDown` visible in `kubectl get nixcluster`.
4. TDD with envtest in `nixcluster_controller_test.go`: Retain path, Teardown happy
   path, teardown failure keeps the finalizer, policy flip to Retain unblocks deletion,
   converge cron suspended before the teardown job starts.
5. Docs: `examples/nixcluster.yaml` and README section on deletion.

### T11 — NIO part of the deck with real output `[ ]`

Depends on T3/T4 (running VMs) and, for the deletion step, T10. Same approach as the
nixcluster part: real output only, fragments in slides, playback scripts in `demo/play/`.

1. Management cluster for NIO: decide where the operator runs (see open question below),
   install NIO there (`config/`, server-side apply as the README requires).
2. Resources in `demo/nio/`: `Machine` per node, `NixBuilder`, `NixCluster` for the
   same `kz-demo` flake (fixture reference: `~/git/github.com/kitsunoff/nio-e2e-flake`).
3. Capture to `demo/output/nio-*.txt`:
   1. `kubectl apply` of the resources;
   2. `kubectl get machines,nixclusters` with status/phase columns;
   3. logs of the converge job created by the operator;
   4. a git commit to the flake → the next converge picks it up (the "Commit → rolled
      out" slide);
   5. `kubectl delete nixcluster kz-demo` → teardown job logs → finalizer gone.
4. Replace or extend the NIO slides ("Машина как k8s-ресурс", "NixosConfiguration",
   "NixCluster", "Коммит → раскатилось само") with these fragments; check that YAML on
   the slides matches the real CRD fields (`api/v1alpha1/*_types.go`).
5. Add NIO steps to the playback scripts (T8): `07-nio-apply.sh`, `08-nio-status.sh`,
   `09-nio-delete.sh`.

Open question for T11: where NIO runs. Options:

1. A 4th Colima VM `kz-mgmt` with single-node k3s (cleanest, but RAM: builder +
   4 VMs on 16 GiB is very tight).
2. NIO inside the `kz-demo` k3s itself (no extra VM, but `kubectl delete nixcluster`
   would tear down the cluster the operator runs on — the delete demo breaks).
3. NIO on `kz-demo`, managing a smaller second cluster on 1–2 extra VMs.

### T7 — Teardown and backup plan `[ ]`

1. Document how to stop the demo VMs (`colima stop --profile kz-node-N`) to free RAM.
2. Deletion of profiles is done by the user only.
3. Backup for the talk: recorded output + `converge --dry-run` that needs no VMs.

## Parallelization plan for subagents

```text
wave 1:  T1 (infra)  ║  T2 (config, eval only)  ║  T6 (slide API fixes)  ║  T8 (playback scripts)  ║  T9 (teardown in nixcluster)
wave 2:  T3 (bootstrap) → T4 (proof)  — one agent, sequential  ║  T10 (NIO teardown, after T9)
wave 3:  T11 (NIO demo) — needs live VMs and T10
wave 4:  T5 (demo slides)  ║  T7 (teardown doc)  ║  T8 final pass on real logs
```

Wave 2 is one agent on purpose: converge and verification share live VM state.
