#!/usr/bin/env bash

export SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age.key
exec nix run nixpkgs#sops updatekeys /etc/nixos/secrets/secrets.yaml
