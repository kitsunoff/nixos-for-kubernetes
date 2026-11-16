{
  description = "nixcluster live demo: kz-demo (k3s + Incus) and kz-mgmt (single k3s)";

  inputs = {
    nixcluster.url = "github:kitsunoff/nixcluster";

    # Reuse nixcluster's locked inputs for a single consistent set.
    nixpkgs.follows = "nixcluster/nixpkgs";
    flake-parts.follows = "nixcluster/flake-parts";
    import-tree.follows = "nixcluster/import-tree";
    disko.follows = "nixcluster/disko";
    sops-nix.follows = "nixcluster/sops-nix";
  };

  outputs =
    inputs@{ flake-parts, import-tree, nixcluster, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # The VMs are aarch64-linux; the CLI also runs on an aarch64 Linux builder.
      systems = [ "aarch64-linux" "x86_64-linux" ];

      imports = [
        nixcluster.flakeModules.default
        # base.nix, clusters/*.nix, nodes/*.nix
        (import-tree ./modules)
      ];
    };
}
