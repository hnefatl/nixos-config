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

      # Awkward special case to put here but hard to inject elsewhere.
      # Some day remove, once the legacy `docker_configs` directory is gone.
      safe.directory = lib.mkIf (config.machine_config.instance == "warthog") [
        "/pool/services/docker_configs"
      ];
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
