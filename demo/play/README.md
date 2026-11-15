# Demo playback

Bash scripts that replay the demo command flow step by step, so the talk needs
no live typing. Each step prints a caption, "types" the command, waits for a key
and then shows the output: the recording from `demo/output/` (default) or the
real command (`DEMO_MODE=live`).

Pure bash and ANSI escapes, no other dependencies. Works with the macOS default
bash 3.2.

## Usage

```bash
# Whole demo, recorded output
demo/play/all.sh

# One step
demo/play/04-kubernetes.sh

# Restart from step 05 after an interruption
DEMO_FROM=05 demo/play/all.sh

# Page long output (converge log) every 30 lines, clear the screen per step
DEMO_PAUSE_LINES=30 DEMO_CLEAR=1 demo/play/all.sh
```

## Keys

| Key | When | Action |
| --- | --- | --- |
| Enter | after the command is typed | show the output |
| Enter | at a page pause | next page |
| `s` | after the command or at a page pause | skip the (rest of the) output |
| `q` | after the command or at a page pause | quit the whole run |

End of input counts as Enter, so `yes '' | demo/play/all.sh` runs unattended.

## Environment variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `DEMO_MODE` | `replay` | `replay` prints recordings, `live` runs the commands |
| `DEMO_TYPE_SPEED` | `0.03` | seconds per typed character, `0` disables the effect |
| `DEMO_PAUSE_LINES` | `0` | pause every N output lines, `0` disables paging |
| `DEMO_CLEAR` | `0` | `1` clears the screen before each step |
| `DEMO_FROM` | `00` | `all.sh` only: first step number, two digits |
| `DEMO_OUTPUT_DIR` | `demo/output` | where recordings are read from |
| `DEMO_KEEP_WARNINGS` | `0` | `1` keeps nix's "Git tree is dirty" warnings |
| `NO_COLOR` | unset | any value disables colors |

## Steps

| Script | Content | Status |
| --- | --- | --- |
| `01-plan.sh` | CLI help, `convergeOrder`, `converge --dry-run` | recorded |
| `02-secrets.sh` | encrypted secrets file, `/run/secrets` on a node | needs T4 |
| `03-converge.sh` | first `converge` | needs T3 |
| `04-kubernetes.sh` | kubeconfig, nodes, pods, API through the VIP | needs T4 |
| `05-incus.sh` | Incus status, cluster list, launch, list | needs T4 |
| `06-vip.sh` | keepalived status and failover | needs T4 |
| `07-rerun.sh` | idempotent second `converge` | needs T3 |
| `08-teardown.sh` | `teardown` | feature in progress (T9) |
| `09-nio-apply.sh` | NIO resources applied | feature in progress (T11) |
| `10-nio-status.sh` | NIO machines and cluster status | feature in progress (T11) |
| `11-nio-delete.sh` | `NixCluster` deletion and teardown | feature in progress (T10, T11) |

A step without a recording prints a dim `[нет записи: <file>]` marker and the run
continues. Steps marked `wip` show a `[в разработке]` tag and are never executed
in live mode.

## Recording format

Recordings live in `demo/output/<file>`. The first line `$ <command>` and the last
line `[exit N]` are stripped on replay, everything in between is printed as is.

```text
$ nix eval .#clusterConfigurations.kz-demo.convergeOrder
[ "sops.gen" "member-kz-node-1" ... ]
[exit 0]
```

## Adding a step

Add one `step` call to an existing script, or a new `NN-name.sh` next to the
others; `all.sh` picks up every `[0-9][0-9]-*.sh` in order.

```bash
#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Caption shown on screen" \
  "command typed and, in live mode, executed from demo/" \
  "recording-file-in-demo-output.txt"   # add: wip  for unfinished features
```

## Live mode

1. Commands run from `demo/` with `bash -c`, exactly as typed on screen.
2. The flake has only Linux systems, so `nix run .#cluster-…` works from the
   Linux control VM, not from macOS. Node addresses in the commands are the
   `eth0` addresses (`192.168.5.x`) reachable from that VM.
3. Every `kubectl` call passes `--kubeconfig kubeconfig/<cluster>.yaml`, and
   `KUBECONFIG` is set to `demo/kubeconfig/kz-demo.yaml` for the command, so
   `~/.kube/config` is never read or written.
4. A failing command prints its exit code and the run continues.
5. `06-vip.sh` stops keepalived on the first node and starts it again in its last step.
