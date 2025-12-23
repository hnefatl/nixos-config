{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  # Tweaked from https://github.com/NixOS/nixpkgs/issues/324859#issuecomment-3263952213
  boot.kernelPatches =
    let
      patchesDir = "${inputs.bore-scheduler-src}/patches/stable/linux-${lib.versions.majorMinor config.boot.kernelPackages.kernel.version}-bore";
    in
    lib.mapAttrsToList (name: _: {
      name = "bore-${name}";
      patch = "${patchesDir}/${name}";
    }) (builtins.readDir patchesDir);

  boot.kernel.sysctl = {
    "kernel.sched_bore" = 1;
    # Other defaults apply: https://github.com/firelzrd/bore-scheduler.
  };
}
