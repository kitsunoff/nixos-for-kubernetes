# kz-node-1 (Colima profile kz-node-1). Facts from demo/NODES.md.
{ ... }:
{
  nixcluster.kz-demo.members.kz-node-1 = {
    install.ip = "192.168.5.3"; # eth0: the builder reaches nodes only here
    install.disk = "/dev/vda"; # wiped on first install

    k3s.role = "server";
    networking.hostName = "kz-node-1";

    lima.eth0 = { mac = "52:55:55:b8:13:8c"; address = "192.168.5.3"; };
    lima.col0 = { mac = "52:55:55:a4:7d:7a"; address = "192.168.106.4"; };
  };
}
