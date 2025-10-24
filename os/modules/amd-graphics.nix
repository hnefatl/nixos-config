{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.rocmPackages.rocm-smi
  ];

  hardware.amdgpu = {
    # Load GPU driver in stage 1, for higher res boot.
    initrd.enable = true;
    opencl.enable = true;
  };
}
