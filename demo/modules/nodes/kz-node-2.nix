# kz-node-2 (Colima profile kz-node-2). Facts from demo/NODES.md.
{ ... }:
{
  nixcluster.kz-demo.members.kz-node-2 = {
    install.ip = "192.168.5.4"; # eth0: the builder reaches nodes only here
    install.disk = "/dev/vda"; # wiped on first install

    k3s.role = "server";
    networking.hostName = "kz-node-2";

    lima.eth0 = { mac = "52:55:55:69:61:42"; address = "192.168.5.4"; };
    lima.col0 = { mac = "52:55:55:8f:77:ca"; address = "192.168.106.5"; };
  };
}
