{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (pkgs.vscode-with-extensions.override {
      vscodeExtensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        jnoortheen.nix-ide
        ms-python.python
        ms-pyright.pyright
        ms-python.black-formatter
        ms-vscode-remote.remote-ssh
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
      ];
    })
    nixfmt-rfc-style
  ];
}
