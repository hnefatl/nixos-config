#!/usr/bin/env bash

set -e

if [[ "$#" -ne 1 ]]; then
    echo "Usage: nix-init <directory>"
    exit 0
fi
cd "$1"

for f in flake.nix .gitignore .vscode/settings.json .envrc ; do
  [ -f $f ] && echo "File $f already exists, exiting." && exit 1
done

cat >flake.nix <<EOF
{
  inputs = {
  };
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = {};
  };
}
EOF

cat >.gitignore <<EOF
/.direnv/
# \`nix build\` output
/result
EOF

mkdir -p .vscode
cat >.vscode/settings.json <<EOF
{
  "files.exclude": {
      ".direnv/": true
  }
}
EOF

cat >.envrc <<EOF
use flake
EOF

direnv allow

git init
git add flake.nix .gitignore .vscode .envrc

