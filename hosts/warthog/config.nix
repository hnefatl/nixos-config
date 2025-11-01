{ pkgs, impermanence, ... }:
{
  imports = [
    ./model.nix
    ./hardware.nix
    ./filesystems.nix
    ./networking.nix
    ./topology.nix
  ];

  system.stateVersion = "25.05";

  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {
    # ftr this seems to enable CUDA support implicitly, making it
    # suitable for encoding (for e.g. Jellyfin).
    datacenter.enable = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;
    open = true;
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      # Necessary because vim keybindings disable this binding?
      bindkey '^R' history-incremental-search-backward
      # Prevents trying to overwrite the impermanence-symlinked history file.
      unsetopt HIST_SAVE_BY_COPY
    '';
    #plugins = [
    #  {
    #    name = "vi-mode";
    #    src = pkgs.zsh-vi-mode;
    #    file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    #  }
    #];
    shellAliases = {
      c = "clear";
      nso = "nh os switch /etc/nixos";
    };
  };
}
