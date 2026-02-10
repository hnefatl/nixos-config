# Shell configuration for direnv when editing nixos configurations.
{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    # For Caddyfile formatting.
    caddy
  ];
}
