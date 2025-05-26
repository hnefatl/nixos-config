{ pkgs, lib, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    vscodevim.vim
    ms-python.python
    ms-vscode-remote.remote-ssh
  ];
})
