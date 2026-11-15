# NODES — Colima VMs for the live nixcluster demo

Recorded on 2026-11-15 (task T1). Host: macOS, Apple Silicon, 16 GiB RAM.
Colima 0.10.1 (`/nix/store/jqjgkby1k6xm1n24c854cqva6cdq4fwq-colima-0.10.1/bin/colima`),
Lima 2.0.3. All VMs: `--vm-type vz --arch aarch64 --network-address --runtime containerd`,
current OS is the stock Colima Ubuntu 24.04 image (kernel 6.8.0-100-generic).

## VMs

| Profile | Role | user-v2 IP (`eth0`) | vzNAT IP (`col0`) | CPU | RAM | Install disk | Extra disk | Boot mode |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `kz-node-1` | `kz-demo` member 1 | 192.168.5.3 | 192.168.106.4 | 2 | 2 GiB | `/dev/vda` (20G) | `/dev/vdb` (20G) | UEFI |
| `kz-node-2` | `kz-demo` member 2 | 192.168.5.4 | 192.168.106.5 | 2 | 2 GiB | `/dev/vda` (20G) | `/dev/vdb` (20G) | UEFI |
| `kz-node-3` | `kz-demo` member 3 | 192.168.5.5 | 192.168.106.6 | 2 | 2 GiB | `/dev/vda` (20G) | `/dev/vdb` (20G) | UEFI |
| `kz-mgmt` | `kz-mgmt` single node (NIO) | 192.168.5.6 | 192.168.106.7 | 2 | 2.5 GiB | `/dev/vda` (20G) | `/dev/vdb` (30G) | UEFI |
| `nix-builder` | control VM (nix, nixos-anywhere) | 192.168.5.1 | 192.168.106.2 | 4 | 4 GiB | — never a target | — | — |

MAC addresses (stable per profile):

| Profile | `eth0` MAC | `col0` MAC |
| --- | --- | --- |
| `kz-node-1` | 52:55:55:b8:13:8c | 52:55:55:a4:7d:7a |
| `kz-node-2` | 52:55:55:69:61:42 | 52:55:55:8f:77:ca |
| `kz-node-3` | 52:55:55:db:f9:22 | 52:55:55:ea:90:96 |
| `kz-mgmt` | 52:55:55:e4:72:e3 | 52:55:55:5f:f9:48 |

## Disk layout (identical on all four nodes, except `vdb` size)

```text
NAME     SIZE TYPE FSTYPE  MOUNTPOINT
vda       20G disk
├─vda1    19G part ext4    /
├─vda15   99M part vfat    /boot/efi
└─vda16  923M part ext4    /boot
vdb       20G disk                      (30G on kz-mgmt)
└─vdb1    20G part ext4    /mnt/lima-colima-<profile>
vdc       53M disk iso9660 /mnt/lima-cidata
```

1. `/dev/vda` is the Lima root disk the firmware boots from. Its size is always 20G
   (Lima `rootDisk` default) and does not follow `--disk`.
2. `/dev/vdb` is the Colima data disk created by `--disk` (20G / 30G).
3. `/dev/vdc` is the cloud-init ISO.
4. `/sys/firmware/efi` exists on every node: boot mode is **UEFI**. The NixOS config
   needs a GPT disk with an ESP plus systemd-boot (or GRUB EFI). BIOS GRUB on
   `/dev/vda1` will not boot.
5. Recommended disko target: `/dev/vda`. `/dev/vdb` can optionally be used for
   `/var/lib` (containerd, Incus storage).

## Networks

Every VM has two NICs:

| Interface | Lima network | Subnet | Gateway | VM ↔ VM | Host ↔ VM |
| --- | --- | --- | --- | --- | --- |
| `eth0` | `user-v2` (gvisor userspace net) | 192.168.5.0/24 | 192.168.5.2 (metric 200) | **yes** | no |
| `col0` | `vzNAT` (macOS vmnet, host bridge `bridge103`) | 192.168.106.0/24 | 192.168.106.1 (metric 300) | **no** | yes |

On the host, every VM port of `bridge103` carries the `PRIVATE` flag, so macOS drops
traffic between VMs on `col0` ("No route to host", ARP fails). Only the host reaches
`192.168.106.x`. VM-to-VM traffic (builder → nodes, k3s, Incus cluster,
keepalived unicast) **must use the `user-v2` addresses (192.168.5.x)**.

Both interfaces get their addresses over DHCP, and the default route goes via `eth0`
(lower metric).

## Proposed keepalived VIP

| Purpose | VIP | Interface |
| --- | --- | --- |
| In-cluster API endpoint (nodes, builder) | **192.168.5.200** | `eth0` |
| Host access (`kubectl` from the Mac) | **192.168.106.200** | `col0` |

Verification done on 2026-11-15:

1. Neither address answered before the test (host ping, TCP probe from `kz-node-2`,
   not in `/var/db/dhcpd_leases`).
2. Both addresses were temporarily added to `kz-node-1`, then moved to `kz-node-3`,
   with a gratuitous ARP after each move. `kz-node-2` reached `192.168.5.200:22` and
   the host pinged `192.168.106.200` both times, and the neighbour caches switched to
   the new MAC right away. The temporary addresses were removed afterwards.
3. Consequence for T2: the keepalived `unicast_src_ip`/`unicast_peer` addresses must be
   the `192.168.5.x` addresses. One VRRP instance on `eth0` can carry both VIPs
   (`192.168.106.200` with `dev col0` in `virtual_ipaddress`).

## Control VM (`nix-builder`)

| Item | Value |
| --- | --- |
| OS | Ubuntu 24.04.2 LTS, aarch64 |
| Nix | `nix (Nix) 2.33.3` |
| Resources | 4 CPU, 4 GiB RAM (profile lowered from 8 GiB), runtime docker |
| SSH from the host | port 2222 on 127.0.0.1, key `~/.ssh/nix-builder-colima` |
| SSH to nodes | root key `/root/.ssh/id_ed25519` (generated in T1, `root@colima-nix-builder`) |

Both public keys are in `/root/.ssh/authorized_keys` on all four nodes:
`~/.ssh/nix-builder-colima.pub` (the host key) and the builder's own root key.

Commands:

```bash
# start the builder (the profile now stores 4 GiB)
colima start --profile nix-builder --memory 4

# shell in the builder from the host
ssh -i ~/.ssh/nix-builder-colima -p 2222 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@127.0.0.1 'source /etc/profile && nix --version'

# from inside the builder: root SSH to a node (verified for all four)
ssh root@192.168.5.3 hostname   # kz-node-1
ssh root@192.168.5.4 hostname   # kz-node-2
ssh root@192.168.5.5 hostname   # kz-node-3
ssh root@192.168.5.6 hostname   # kz-mgmt

# from the host: root SSH to a node over col0
ssh -i ~/.ssh/nix-builder-colima root@192.168.106.4 hostname

# node shell via Colima (works only while the stock image runs)
colima ssh --profile kz-node-1
```

## Repository visibility inside the builder

The builder mounts the whole host home via virtiofs, read-write:

```text
mount0 on /Users/kitsunoff type virtiofs (rw,relatime)
```

`/Users/kitsunoff/git/github.com/kitsunoff/nixos-for-kubernetes` is visible at the same
path and is writable (a write test succeeded), so `nix` can run against `demo/` from
inside the builder directly.

## Caveats

1. **No VM-to-VM traffic on `col0`.** Use `192.168.5.x` for anything between VMs. The
   `192.168.106.x` addresses are for the host only.
2. **`user-v2` is not reachable from the host.** The host can only use `col0`
   addresses or the `192.168.106.200` VIP.
3. **Address stability.** The `user-v2` addresses came from DHCP in start order (the
   builder got `.1`). They have not yet been tested across VM restarts or a
   nixos-anywhere kexec. After installing NixOS, re-check `ip -brief addr` and pin the
   addresses in the NixOS config, for example with a static `eth0` address on
   `192.168.5.0/24`, gateway `192.168.5.2`, matched by MAC.
4. **NixOS must keep both NICs up**, `eth0` via DHCP or static and `col0` via DHCP.
   Otherwise the node becomes unreachable from the builder or from the host.
5. **Colima lifecycle after NixOS install.** `colima start`/`colima ssh` expect the Lima
   guest agent and cloud-init from the Ubuntu image. After nixos-anywhere replaces
   `/dev/vda`, a later `colima start` of that profile will probably time out waiting for the
   guest agent, even if the VM itself boots. Use plain `ssh root@<ip>` after install.
6. **Stale disk lock.** On the first start, `nix-builder` failed with `failed to run
   attach disk "colima-nix-builder", in use by instance` (left over from an unclean
   stop). Fix:
   `LIMA_HOME=~/.colima/_lima limactl disk unlock colima-nix-builder`.
7. **Builder side effects.** Starting `nix-builder` auto-restarts an old kind container
   (`go-operator-test-e2e-control-plane`) inside it, which takes part of the builder's
   4 GiB. Colima also switched the host docker context to `colima-nix-builder`.
8. **Host memory is tight.** With all 5 VMs running, macOS memory pressure was level 2
   (warning; 4 = critical), "free" 37%, swap 9.8 of 10 GiB used, compressor 7.2 GiB.
   OrbStack was running (about 2 GiB RSS) and was the largest consumer. Quit OrbStack
   and other heavy apps before provisioning, and stop `nix-builder` after the install.
9. Old profiles `node-01`, `node-02` stay stopped and untouched.
