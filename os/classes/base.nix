# Common configuration for all machines. Should be low-dep.

{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../modules/sops.nix
    ../users/users.nix
    ../modules/nix.nix
    ../modules/neovim.nix
  ];

  networking.hostName = config.machine_config.hostname;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # TTY config
  console = {
    keyMap = "uk";
    # Font details: https://files.ax86.net/terminus-ttf/README.Terminus.txt
    # 1 is codepage, 16 is size, n is normal style.
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    acpi
    sysstat # iostat
    python3
    unzip
    p7zip
    nix-inspect
    jujutsu
  ];

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.nh.enable = true;

  services.fwupd.enable = true;

  # Useful for debugging available fonts.
  fonts.fontDir.enable = true;

  # Generically useful security setup.
  security.polkit.enable = true;
}
