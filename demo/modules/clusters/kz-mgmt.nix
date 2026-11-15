# kz-mgmt: one k3s server. Runs the NIO operator and doubles as the Nix
# builder for kz-demo once the nix-builder VM is stopped.
{ ... }:
{
  nixcluster.kz-mgmt =
    { clusterModules, self, config, lib, ... }:
    let
      member = {
        k3s.extraServerFlags =
          [ "--disable=traefik" ]
          # kubectl from the Mac connects over col0.
          ++ map (m: "--tls-san=${m.lima.col0.address}") (lib.attrValues config.members);

        # Remote builder: root on the builder VM / NIO uses this daemon over SSH.
        nix.settings.trusted-users = [ "root" ];
      };
    in
    {
      imports = with clusterModules; [ disko k3s ];

      disko.enable = true;
      k3s.enable = true;

      defaultNixosConfiguration =
        self.nixosConfigurations.base.extendModules { modules = [ member ]; };
    };
}
