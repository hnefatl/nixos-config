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
    - `zkeys` ZFS pool: contains just the keys for encrypted ZFS datasets on the machine. ZFS used here for the checksumming. Individual dataset keys are backed up to a Dashlane secure note.
  - `zroot` main ZFS pool partition
    - `zroot/enc`: encrypted parent dataset.
      - `zroot/enc/...`: general encrypted datasets.
      - `zroot/enc/snap`: auto-snapshotted parent dataset.
        - `zroot/enc/snap/...`: general encrypted+snapshotted datasets.
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

### Configure LUKS

```
# Inspect the current keys
$ sudo systemd-cryptenroll /dev/nvme0n1p2
SLOT TYPE
   0 password
   1 tpm2
   2 password   # ooh this one might be new and not enrolled in TPM

# Configure a LUKS password for human recovery
$ sudo systemd-cryptenroll /dev/disk --password

# Generate an *unrelated* decryption key in the TPM
$ sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2
```
