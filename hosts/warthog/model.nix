{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "warthog";
    hostname = "warthog";
    formFactor = "server";
    autoLogin = false;
    isWork = false;
  };
}
