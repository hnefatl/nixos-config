#!/usr/bin/env bash

export SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age.key
exec nix run nixpkgs#sops /etc/nixos/secrets/secrets.yaml
