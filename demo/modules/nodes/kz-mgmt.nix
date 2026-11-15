# kz-mgmt (Colima profile kz-mgmt). Facts from demo/NODES.md.
{ ... }:
{
  nixcluster.kz-mgmt.members.kz-mgmt = {
    install.ip = "192.168.5.6"; # eth0: the builder reaches nodes only here
    install.disk = "/dev/vda"; # wiped on first install

    k3s.role = "server";
    networking.hostName = "kz-mgmt";

    lima.eth0 = { mac = "52:55:55:e4:72:e3"; address = "192.168.5.6"; };
    lima.col0 = { mac = "52:55:55:5f:f9:48"; address = "192.168.106.7"; };
  };
}
