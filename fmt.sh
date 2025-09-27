#!/usr/bin/env bash

shopt -s globstar

ls **/*.nix | grep -v result | xargs nix run nixpkgs#nixfmt-rfc-style -- --width=120

