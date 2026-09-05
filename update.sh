#!/usr/bin/env bash

cd /etc/nixos/os
nix flake update
cd ../home
nix flake update
