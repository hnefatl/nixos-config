{
  networking = {
    nameservers = [ "10.20.0.1" ];
    # Resolving e.g. `laptop.lan` doesn't work with `dig` but does with `resolvectl query`
    # which I think is all that matters? Seems to be working okay for prometheus at least.
    search = [ "lan" ];
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      address = [ "10.20.1.3/16" ];
      gateway = [ "10.20.0.1" ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking.useDHCP = false;
}
