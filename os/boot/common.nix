{ config, lib, ... }:

{
  boot.loader = {
    # KVM has a bit of latency, allow a bit longer.
    timeout = if config.machine_config.instance == "warthog" then 5 else 2;
    efi.canTouchEfiVariables = true;
  };
}
