#!/usr/bin/env bash

set -e

nixos-rebuild build --flake /etc/nixos/os#desktop

sudo rm -rf /tmp/initrd
sudo mkdir -p /tmp/initrd

cd /tmp/initrd
nix shell nixpkgs#dracut --command sudo lsinitrd --unpack /etc/nixos/result/initrd
echo "Unpacked to /tmp/initrd"
