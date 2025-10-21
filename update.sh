#!/usr/bin/env bash

exec nix flake update --flake /etc/nixos/os# --flake /etc/nixos/home#
