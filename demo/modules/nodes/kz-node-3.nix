# kz-node-3 (Colima profile kz-node-3). Facts from demo/NODES.md.
{ ... }:
{
  nixcluster.kz-demo.members.kz-node-3 = {
    install.ip = "192.168.5.5"; # eth0: the builder reaches nodes only here
    install.disk = "/dev/vda"; # wiped on first install

    k3s.role = "server";
    networking.hostName = "kz-node-3";

    lima.eth0 = { mac = "52:55:55:db:f9:22"; address = "192.168.5.5"; };
    lima.col0 = { mac = "52:55:55:ea:90:96"; address = "192.168.106.6"; };
  };
}
