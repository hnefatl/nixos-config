{
  config,
  pkgs,
  lib,
  ...
}:
{
  # On autologin systems, the gnome keyring isn't initialised. Just store the spotify passwords in plaintext.
  home.packages =
    if config.machine_config.autoLogin then
      [
        (pkgs.symlinkJoin {
          name = "spotify";
          paths = [ pkgs.spotify ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/spotify \
              --add-flags "--password-store=basic"
          '';
        })
      ]
    else
      [ pkgs.spotify ];
}
