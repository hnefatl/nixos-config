{ config, ... }:
{
  programs.git = {
    enable = true;

    userEmail = "hnefatl@gmail.com";
    userName = "Keith Collister";

    signing = {
      signByDefault = true;
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    extraConfig = {
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
    };
  };

  # At some point would be good to refactor these into a "user" config so can reference in
  # both os/users/keith.nix and here.
  # Want signing vs authorization keys? Since don't really want to be able to SSH using warthog keys?
  # Maybe should just switch to GPG for signing keys? Could put in sops but then idk about root of trust.
  home.file.".config/git/allowed_signers".text = ''
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVXUPyteZDsBXLsiFSVpW8Qr9qXi4wY7NkEQLeADAim keith@desktop
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINH2aSRfXbucOu8ZxBUFEGv8BfeYG0ZOsHfVJcznpwKY keith@warthog
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister
  '';
}
