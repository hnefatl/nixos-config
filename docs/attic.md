# Attic

Attic is a self-hosted binary cache for Nix store artefacts.

For HTTPS connections, the server deployment relies on Traefik.

```sh
# On server:
$ sudo atticd-atticadm make-token --sub="keith@laptop" --validity="1y" --pull=prod --push=prod --create-cache=prod --configure-cache=prod --destroy-cache=prod

# On client:
$  nix run nixpkgs#attic-client -- login warthog https://attic.warthog.keith.collister.xyz "ABC..."

$ attic cache create warthog:prod
$ attic cache info warthog:prod
```

TODO: `attic watch-store` to push from store to local cache.

