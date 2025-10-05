# Disk Security

## Threat model

Primary concerns:
- A thief or intermediately skilled but non-targeted physical adversary:
  - can't access the OS due to secure boot+passwords.
  - can't read data off the disks due to bootstrap encryption keys being stored in the TPM.
- A remote adversary _with access to_:
  - Warthog: can't trivially read backups of other machines stored on Warthog.
  - offsite backup machine: can't access the data in the backups.
- Corruption of a _single_ disk's encryption metadata (LUKS header, TPM) can be recovered from ~easily.
- I can securely erase disks easily by overwriting e.g. a LUKS header.

I'm not designing for targeted attackers [or wrenches](https://xkcd.com/538).

## Layout

TL;DR: use ZFS native encryption where possible, it's nice for supporting incremental send/recv backups on untrusted offsite machines. Use LUKS to protect the bootstrap keys for ZFS datasets. Avoid ZFS-in-LUKS layering because double-encryption is wasteful and increases the chance of losing data by losing an outer layer's key.

- Boot disk (GPT partition table)
  - Unencrypted FAT32 `/boot` partition (ideally secure-booted)
  - LUKS partition (autounlocked via TPM)
    - `zfskeys` ZFS pool: contains just the keys for encrypted ZFS datasets on the machine. ZFS used here for the checksumming. Individual dataset keys are backed up to a Dashlane secure note.
  - `zroot` main ZFS pool partition
    - `zroot/enc`: encrypted parent dataset.
      - `zroot/enc/...`: general encrypted datasets.
      - `zroot/enc/snap`: auto-snapshotted parent dataset.
        - `zroot/enc/snap/...`: general encrypted+snapshotted datasets (e.g. `/home`, `/nix`).
  - Swap partition: LUKS encrypted, but with a TPM key only, no passphrase (autounlock and don't mind losing).
- Other disks:
  - ZFS full-disk e.g. `zgames`/`zfast`/`zslow`/...
    - `zfoo/enc/snap/...` datasets.

### Design rationale

The small LUKS partition next to a non-LUKS ZFS partition is a weird setup. My rationale is:

1. I want to use ZFS native encryption where possible because it makes snapshot send/recv convenient for offsite backups to untrusted machines.

1. ZFS encrypted datasets can be decrypted using the password/key material, and storing this in the TPM is not currently supported. So this material needs to be stored encrypted at rest on disk, most easily within a small LUKS partition. Leaving this unencrypted would make the disk vulnerable to a physical attacker just reading the plaintext password for the adjacent ZFS dataset.

1. If a LUKS header is corrupted, the volume becomes inaccessible. The only way to recover is to have a backup of the LUKS header+a corresponding password/key material. This is fiddly because LUKS headers are large, so would ideally be e.g. backed up inside ZFS. But that creates a cyclic key recovery dependency.

1. The simplest way to avoid this is to limit the data inside LUKS only to keys which are already backed up elsewhere, so that a corrupt partition can just be **replaced**, not restored.

Finally, the ZFS encryption keys need to be backed up offsite but in a different place to the encrypted ZFS dataset snapshots: otherwise an attacker in the remote backups has both the datasets and the keys. I'm just using Dashlane's secure notes for this.

## Setup

### Partitioning

```sh
# Use fdisk to layout disk with:
# - 10GB boot partition
# - 1GB zfskeys partition
# - <remaining space> data partition
# - 32GB swap partition
$ fdisk ...

# Make swap
$ cryptsetup luksFormat /dev/...
$ systemd-cryptsetup attach swap /dev/...
# Enter password, don't bother with TPM yet.
$ mkswap /dev/mapper/swap
$ swapon /dev/mapper/swap

# Make zfskeys
$ cryptsetup luksFormat /dev/...
$ systemd-cryptsetup attach zfskeys /dev/...
$ zpool create -o ashift=12 -O atime=off -O compression=on -O mountpoint=legacy zfskeys /dev/mapper/zfskeys
# Location is important, it's where the initrd will look for the keys during stage 1 boot.
$ mkdir /zfskeys
$ mount -tzfs zfskeys /zfskeys
# Generate root zfs password
$ tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 20 | tee /zfskeys/zroot-enc.priv
$ chmod u=r,go= /zfskeys/zroot-enc.priv

# Make data partition
$ zpool create -o ashift=12 -O atime=off -O compression=on -O mountpoint=legacy zfskeys -O acltype=posix -O xattr=sa /dev/...
# Make encrypted dataset
$ zfs create -o encryption=on -o keyformat=passphrase -o keylocation=file:///persist/secrets/zfs/zslow.priv zslow

# Make other datasets e.g. /nix, /home/keith, /root
# Mount them to /mnt/... as they should be structured.
# Set autosnapshot property with:
# zfs set com.sun:auto-snapshot=true zroot/enc/snap
```

### OS installation

Work with `/mnt` and `nixos-install` etc.

### Secure Boot

Follow https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md.

### Autounlock disks on boot

TODO: check compliance with https://oddlama.org/blog/bypassing-disk-encryption-with-tpm2-unlock/. Deterministic disk unlock order sounds tricky? Looks like missing `tpm2-measure-pcr=yes`

This works even on devices without secure boot, if you omit the `--tpm2-pcrs=...` flag and use systemd.

If using secure boot, this needs to be done once inside the secure-booted OS.

```sh
# See what LUKS passphrases currently exist
$ systemd-cryptenroll /dev/...
SLOT TYPE
   0 password

# Create a passphrase in the TPM
$ systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 /dev/...
$ systemd-cryptenroll /dev/...
SLOT TYPE
   0 password
   1 tpm2

# Should autounlock based on TPM, if booted in secure boot.
$ systemd-cryptsetup attach foo /dev/...
$ ls /dev/mapper/foo
/dev/mapper/foo
```
