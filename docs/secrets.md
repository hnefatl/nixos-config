# Per-machine secrets

Per-machine secrets should be stored in `/etc/nixos/machine_secrets`, owned by `root:root`.

# Shared secrets

[sops-nix](https://github.com/Mic92/sops-nix) allows encrypting secrets and committing them to the repository. This is useful for values needing to be shared between computers, e.g. common user passwords.

Shared secrets are configured in [`.sops.yaml`](/.sops.yaml): each machine has an AGE key at `/etc/nixos/machine_secrets/age.key` which identifies it and authorises it to access the secrets. Enrolling a new machine requires using a trusted machine to decrypt then re-encrypt the secrets to include that machine's key.

Shared secrets are stored encrypted in [`secrets.yaml`](/secrets/secrets.yaml).

# System Installation

1. Generate any per-machine secrets:
   ```sh
   $ sudo mkdir /mnt/etc/nixos/machine_secrets
   $ sudo chown root:root /mnt/etc/nixos/machine_secrets
   ...
   ```

1. Generate the AGE key for the machine using:

   ```sh
   $ nix-shell -p age --command "age-keygen -o /mnt/etc/nixos/machine_secrets/age.key"
   Public key: age...
   ```

1. Copy the public key to an existing machine and update [`.sops.yaml`](/.sops.yaml) to authorise the new machine.

1. Run [`secrets/update.sh`](/secrets/update.sh) on the existing machine to regenerate the encrypted secrets.

1. Copy [`secrets.yaml`](/secrets/secrets.yaml) and [`.sops.yaml`](/.sops.yaml) to the new machine (e.g. by pushing a git commit or `rsync`).

Run `nixos-install` using `--no-root-pasword`: the root password will be set from the stored secrets on boot.

Important: verify that the output of `nixos-install` doesn't include lines like:

```
warning: password file ‘/run/secrets-for-users/user_passwords/keith’ does not exist
cannot read keyfile '/etc/nixos/secrets/age.key': open /etc/nixos/secrets/age.key: no such file or directory
```

These indicate that secrets above were misconfigured, and the new OS will be locked and require rescue.
