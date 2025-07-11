{ pkgs, lib, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    bbenoist.nix
    ms-python.python
    ms-pyright.pyright
    ms-python.black-formatter
    ms-vscode-remote.remote-ssh
    rust-lang.rust-analyzer
    tamasfe.even-better-toml
  ];
})
