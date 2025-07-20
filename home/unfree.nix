{
  # Allow unfree packages inside home-manager
  nixpkgs.config.allowUnfree = true;

  # Allow unfree packages during runs of e.g. `nix shell`.
  # Still requires setting `--impure`, e.g. `nix run --impure nixpkgs#unigine-superposition`.
  home.file.".config/nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
  '';
}
