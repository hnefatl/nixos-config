{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Fix for wayland blurriness.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
    (pkgs.vscode-with-extensions.override {
      vscodeExtensions =
        with pkgs.vscode-extensions;
        [
          vscodevim.vim
          jnoortheen.nix-ide
          ms-python.python
          ms-pyright.pyright
          ms-python.black-formatter
          ms-vscode-remote.remote-ssh
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
        ]
        ++ lib.optionals (!config.machine_config.isWork) [
          vscode-extensions.github.copilot
        ];
    })
    nixfmt-rfc-style
  ];
}
