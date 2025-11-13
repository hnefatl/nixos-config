{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "e323cc57-c29f-4f55-b58c-26846ea70b87";
    swap = "43e06eaf-4467-4c62-87c8-ca4166995983";
    boot = "89d515e1-28b0-4268-a3e8-e3066cae6ad8";
  };

  fileSystems."/games" = {
    device = "zgames/games";
    fsType = "zfs";
    options = [
      "nofail" # Don't fail to boot if this disk goes away.
      "noauto" # Don't mount on boot, only when accessed.
      "x-systemd.automount"
    ];
  };
}
