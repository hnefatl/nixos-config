#!/usr/bin/env bash

ls **/*.nix | grep -v result | xargs nix run nixpkgs#nixfmt-rfc-style -- --width=120

