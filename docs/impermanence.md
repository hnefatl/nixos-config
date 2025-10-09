# Impermanence

https://github.com/nix-community/impermanence

## System Installation

When installing the system from a live CD, remember to put files in `/mnt/persist/etc/nixos` instead of `/mnt/etc/nixos`, and use e.g.:

```
$ nixos-install --no-root-password --flake /mnt/persist/etc/nixos#warthog
```

On boot of the actual OS, `/etc/nixos` will be bind-mounted to `/persist/etc/nixos` as expected.

Remember to:
```sh
$ mkdir -p /mnt/persist/home/keith
# Probably need to look up uid for this.
$ sudo chown keith:users /mnt/persist/home/keith
```
