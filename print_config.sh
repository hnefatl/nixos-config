#!/usr/bin/env bash

if [[ $# -ne 3 ]] ; then
    echo "Usage: print_config.sh (os|host) <hostname> <variable path>"
    exit 1
fi

nix eval "./${1}#nixosConfigurations.${2}.config.${3}"
