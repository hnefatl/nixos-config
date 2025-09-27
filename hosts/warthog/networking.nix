{
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      address = [
        "10.20.1.3/16"
      ];
      routes = [
        { Gateway = "10.20.0.1"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
  networking.useDHCP = false;
}
