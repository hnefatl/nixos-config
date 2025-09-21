{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "warthog";
    hostname = "warthog";
    hostid = "d818a96b";
    formFactor = "server";
    autoLogin = false;
    isWork = false;
  };
}
