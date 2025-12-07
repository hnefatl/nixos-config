{ config, lib, ... }:
{
  programs.git = {
    enable = true;
    signing = {
      signByDefault = true;
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    settings = {
      user = {
        email = "hnefatl@gmail.com";
        name = "Keith Collister";
      };

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
