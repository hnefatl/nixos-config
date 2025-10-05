{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "99a5dcba-1b59-49bc-8a51-5661d21d180b";
    swap = "6218dca0-7296-49c4-9f53-297fac74fbd7";
    boot = "88b38164-72bb-460c-83f6-218fb879aca8";
  };

  fileSystems."/games" = {
    device = "zpoolgames/games";
    fsType = "zfs";
    options = [
      # Don't mount on boot, only when accessed.
      "noauto"
      "x-systemd.automount"
    ];
  };
}
