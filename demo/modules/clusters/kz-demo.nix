# kz-demo: three VMs, each one a k3s server (embedded etcd) and an Incus
# cluster member. sops delivers the secrets, keepalived holds the API VIP.
{ ... }:
{
  nixcluster.kz-demo =
    { clusterModules, self, config, lib, ... }:
    let
      apiVip = "192.168.5.200"; # eth0: nodes and the builder
      hostVip = "192.168.106.200"; # col0: kubectl from the Mac

      # Every address a client may use to reach the k3s API.
      nodeAddresses = lib.concatMap
        (m: [ m.lima.eth0.address m.lima.col0.address ])
        (lib.attrValues config.members);

      # NixOS settings shared by all kz-demo members.
      member = {
        k3s.extraServerFlags =
          [ "--disable=traefik" ] # 2 GiB nodes: no ingress needed for the demo
          ++ map (ip: "--tls-san=${ip}") ([ apiVip hostVip ] ++ nodeAddresses);

        # The k3s module opens the API/etcd/kubelet ports; the rest is ours.
        networking.firewall = {
          allowedTCPPorts = [ 8443 ]; # Incus cluster API
          allowedUDPPorts = [ 8472 ]; # flannel VXLAN between nodes
          # Incus switches the firewall to nftables; keepalived's iptables rule
          # does not apply there, so VRRP is allowed the nftables way.
          extraCommands = lib.mkForce "";
          extraInputRules = "ip protocol vrrp accept";
        };

        # The demo secret below, decrypted to /run/secrets/demo/token.
        sops.secrets."demo/token" = { };
        # nixcluster sets a relative path, which sops-nix rejects; point it at
        # the encrypted file inside this flake instead.
        sops.defaultSopsFile = lib.mkForce ../../secrets/kz-demo.yaml;
      };
    in
    {
      imports = with clusterModules; [ disko k3s incus sops keepalived ];

      disko.enable = true;
      k3s.enable = true;
      sops.enable = true;

      incus.enable = true;
      incus.cluster = {
        enable = true;
        storageBackend = "dir"; # no spare block device needed
      };

      # Generated on the first converge, encrypted into secrets/kz-demo.yaml.
      sops.providers.demo.generate = _: {
        "demo/token" = "head -c 24 /dev/urandom | base64 | tr -d '/+='";
      };

      # Unicast VRRP between the eth0 addresses: multicast is not reliable on
      # Lima networks. The master also carries the host-facing VIP on col0.
      keepalived.enable = true;
      keepalived.instances.k3s-api = {
        interface = "eth0";
        vip = apiVip;
        vips = [ "${hostVip}/24 dev col0" ];
        nodes = lib.attrNames config.members; # first one is MASTER
        virtualRouterId = 51;
      };

      defaultNixosConfiguration =
        self.nixosConfigurations.base.extendModules { modules = [ member ]; };
    };
}
