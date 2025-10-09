{ config, lib, ... }:
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
      credential.helper = "store";
    };
  };

  home.file.".config/git/allowed_signers".text =
    let
      keys = import ../../common/ssh_keys.nix;
      toSignerLine = k: "* " + k;
      toSignerLines = ks: builtins.map toSignerLine (builtins.attrValues ks);
    in
    lib.strings.concatLines (toSignerLines keys.keith);
}
