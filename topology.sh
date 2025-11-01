#!/usr/bin/env bash

set -e

STORE_PATH=$(nix build \
  --no-link --print-out-paths \
  ./os#topology.x86_64-linux.config.output)

cp "${STORE_PATH}"/* docs/topology/
