# The NixOS base every demo VM inherits: a Colima `vz` VM on Apple Silicon.
# Per-node facts (addresses, MACs) live in modules/nodes/*.nix.
{ inputs, ... }:
let
  # Each VM has two NICs (see demo/NODES.md):
  #   eth0  Lima user-v2, 192.168.5.0/24   the only network VMs reach each other on
  #   col0  vzNAT,        192.168.106.0/24 host <-> VM only
  # NixOS does not know Lima's names, so they are pinned by MAC. Addresses are
  # static: DHCP hands them out in VM start order, which is not stable.
  limaNics =
    { config, lib, ... }:
    let
      nic = lib.types.nullOr (lib.types.submodule {
        options.mac = lib.mkOption { type = lib.types.str; };
        options.address = lib.mkOption { type = lib.types.str; };
      });
      cfg = config.lima;

      pin = name: n: {
        links."10-${name}" = {
          matchConfig.MACAddress = n.mac;
          linkConfig.Name = name;
        };
        networks."10-${name}" = {
          matchConfig.Name = name;
          address = [ "${n.address}/24" ];
        };
      };
    in
    {
      options.lima = {
        eth0 = lib.mkOption { type = nic; default = null; };
        col0 = lib.mkOption { type = nic; default = null; };
      };

      config = lib.mkMerge [
        (lib.mkIf (cfg.eth0 != null) {
          systemd.network = lib.mkMerge [
            (pin "eth0" cfg.eth0)
            {
              # Default route and DNS go through the user-v2 gateway.
              networks."10-eth0".gateway = [ "192.168.5.2" ];
              networks."10-eth0".dns = [ "192.168.5.2" ];
            }
          ];
        })
        (lib.mkIf (cfg.col0 != null) {
          systemd.network = pin "col0" cfg.col0;
        })
      ];
    };
in
{
  flake.nixosConfigurations.base = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      limaNics
      {
        nixpkgs.hostPlatform = "aarch64-linux";

        # Colima vz VMs boot UEFI; the disk layout (GPT + ESP) comes from the
        # nixcluster disko module and `install.disk`.
        boot.loader.systemd-boot.enable = true;
        boot.loader.systemd-boot.configurationLimit = 5;
        # Boot through the removable-media fallback path; do not rely on the
        # VM's EFI variable store.
        boot.loader.efi.canTouchEfiVariables = false;
        boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_net" ];
        boot.kernelParams = [ "console=hvc0" ];

        networking.useNetworkd = true;
        networking.useDHCP = false;

        # converge reaches every member over SSH as root.
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "prohibit-password";
        };
        users.users.root.openssh.authorizedKeys.keys = [
          # root on the nix-builder VM (runs converge / nixos-anywhere)
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmI9YSjKID+wNWkRoAMP94mIaTeCqqLVGPZf7YgmnYR root@colima-nix-builder"
          # the Mac (ssh over col0)
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUOjQFNnYdT8i8t14J9D3whqCYir2x/YaODwqUfiqYt nix-builder-colima"
        ];

        # nixos-rebuild on the target needs flakes.
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # 2 GiB of RAM per node: keep the system lean.
        documentation.enable = false;

        system.stateVersion = "25.11";
      }
    ];
  };
}
