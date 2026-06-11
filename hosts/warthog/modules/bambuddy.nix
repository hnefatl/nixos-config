{ lib, ... }:
{
  users.users.bambuddy = {
    isSystemUser  = true;
    uid = 2000;
    group = "bambuddy";
  };
  users.groups.bambuddy = {
    gid = 2000;
  };

  networking.firewall = {
    # https://wiki.bambuddy.cool/features/virtual-printer/#required-ports
    allowedTCPPorts = [
      3000
      3002
      8883
      6000
      322
      990
      50000
      50001
      50002
      50003
      50004
      50005
      50006
      50007
      50008
      50009
    ];
    #] ++ (lib.range 50000 50029);
    allowedUDPPorts = [
      2021
    ];
  };
}
