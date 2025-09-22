{ config, pkgs, ... }:
{
  imports = [
    ../modules/unfree.nix
    ../modules/ssh.nix
    ../modules/git.nix
  ];

  home = {
    username = "keith";
    # Need to use `config...` rather than just `username` to get lazy evaluation.
    homeDirectory = "/home/${config.home.username}";

    packages = [
      # Utility scripts
      (pkgs.callPackage ../scripts/nix-init.nix { inherit pkgs; })
    ];

    shellAliases = {
      c = "clear";
      cl = "clear ; ls";
      nso = "nh os switch /etc/nixos/os";
      nsh = "nh home switch /etc/nixos/home";
      alert = "echo -e '\\a'";
    };
  };

  programs.home-manager.enable = true;
  programs.nh.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      ignoreDups = true;
      # Don't update a terminal with the latest commands from other terminals.
      # Causes confusing "up arrow is the last command run in any zsh, not this zsh".
      share = false;
    };
    initContent = ''
      # Necessary because vim keybindings disable this binding?
      bindkey '^R' history-incremental-search-backward
    '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      syntax enable
      set autoindent
      set shiftwidth=4
      set tabstop=4
      set smarttab
      set expandtab
      set hlsearch
      set smartcase
      set relativenumber
      set number

      " Re-open at previous position in file: https://stackoverflow.com/a/774599
      if has("autocmd")
        au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
          \| exe "normal! g'\"" | endif
      endif
    '';
  };

  programs.ranger.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      # Lower verbosity output
      hide_env_diff = true;
    };
  };

  systemd.user.enable = true;

  home.stateVersion = "24.11";
}
