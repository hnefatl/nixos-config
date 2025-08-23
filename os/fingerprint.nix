{ config, lib, ... }:

lib.mkIf config.machine_config.hasFingerprintReader {
  services.fprintd.enable = true;
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  security.pam.services.swaylock = {
    fprintAuth = true;
    # Allow passwords to unlock the lockscreen, not just fingerprint.
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
    '';
  };
}
