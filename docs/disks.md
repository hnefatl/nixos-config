# Disks

## Layout

General rationale: use ZFS native encryption where possible, it's nice for supporting incremental send/recv backups on untrusted offsite machines. Use LUKS to protect the bootstrap keys for ZFS datasets. Avoid ZFS-in-LUKS layering because double-encryption is wasteful and increases the chance of losing data by losing an outer layer's key.

- Boot disk (GPT partition table)
  - Unencrypted FAT32 `/boot` partition (ideally secure-booted)
  - **LUKS partition** (autounlocked via TPM)
    - `zkeys` ZFS pool: contains just the ZFS keys for encrypted ZFS datasets on the machine. Individual keys are backed up to a Dashlane secure note.
  - `zroot` main ZFS pool partition
    - `zroot/enc`: encrypted parent dataset.
      - `zroot/enc/...`: general encrypted datasets.
      - `zroot/enc/snap`: auto-snapshotted parent dataset.
        - `zroot/enc/snap/...`: general encrypted+snapshotted datasets.
- Other disks:
  - ZFS full-disk e.g. `zgames`/`zfast`/`zslow`/...
    - `zfoo/enc/snap/...` datasets.

## Backing up root key material

### Requirements

1. ZFS encrypted datasets can be decrypted using just the password/key material. This material needs to be encrypted at rest on disk to prevent an attacker just reading the adjacent key.

1. If a LUKS header is corrupted, the volume can only be recovered using `cryptsetup luksHeaderRestore` with a backup of the header and a valid authentication to a keyslot in the backup (e.g. a password or a TPM). LUKS volumes only protect boot disks, which are either impermanent (Warthog) or backed up to Warthog ("user documents"), but it's convenient to have a recovery procedure.

1. LUKS headers are large enough that they need to be treated as data and backed up, they can't be written on paper somewhere. So the LUKS headers are backed up inside the ZFS datasets.

1. LUKS volumes contain the bootstrap ZFS dataset encryption keys, so a machine without a working LUKS boot disk cannot access data within ZFS.

(2) and (3) form a cyclic dependency: the backed-up LUKS headers are required to get the ZFS encryption keys to get the backed-up LUKS headers. To break the cycle, the ZFS dataset encryption keys need to be backed up independently, so that LUKS or ZFS recovery can be performed if either is corrupted.

Additionally, the ZFS datasets are backed up offsite to an Oracle VM. The ZFS encryption keys must also be backed up offsite, but not to the same location, otherwise a breach of the VM exposes both the ZFS datasets and their encryption keys.



### Strategy

- LUKS headers and passwords are backed up to Warthog as `/pool/backup/luks_headers/<wwn>_<uid>.header` and `/.../<wwn>_<uid>.password`. These files are encrypted in a ZFS volume, snapshotted, and backed up offsite.

  If the LUKS header is corrupted, then it's impossible to decrypt the volume. This data is outside ZFS and used on N=0 redundancy boot drives, so vulnerable to corruption.

  Data on boot drives should be somewhat protected, so being able to restore access isn't _critical_ but is convenient. Data on boot drives should be either:
  - Reconstructible, e.g. Warthog's impermanence-enabled boot disk.
  - Snapshotted and backed up to Warthog.

- ZFS encrypted snapshots

  Non-boot disks are fully ZFS'd and use native encryption instead of LUKS, in order to support encrypted snapshot send/recv.

  The encryption keys are stored in 




## Encryption

LUKS headers for all my disks, along with passwords. If a disk's LUKS header is corrupted, then recovery is impossible even with a password. The only way to recover the data is using `cryptsetup luksHeaderRestore` with a backup header.

File format is:
- `<wwn>_<uuid>.header`: the LUKS header file
- `<wwn>_<uuid>.password`: the password for the header

The `wwn` and `uuid` are the WWN and PARTUUID of the partition housing the LUKS volume, given by:
```sh
$ lsblk -o name,wwn,partuuid
NAME                                          WWN                                  PARTUUID
nvme0n1                                       eui.e8238fa6bf530001001b448b4ddc9578 
├─nvme0n1p1                                   eui.e8238fa6bf530001001b448b4ddc9578 1fd3542b-4c9d-4355-ba94-2336252adfa1
└─nvme0n1p2                                   eui.e8238fa6bf530001001b448b4ddc9578 4ea8f160-0315-4704-a1bd-0bb476652cfd
  └─luks-338b49cc-7793-41d8-ba2b-fb96794f3748
```

The naming scheme intends to make it obvious which disk+partition the header is for, even if metadata about the LUKS volume itself is unreadable.

## Threat model

I'm primarily concerned with:
- being able to erase disks easily by overwriting the LUKS header.
- basic "a thief can't just plug the disk in and read data" hygiene.

Intent is that if an attacker has managed to get these, they won't physically have my disks. If they have my disks, they won't have these (due to secure boot). If they have both, it's https://xkcd.com/538.

## Setup

Boot drives should meet these characteristics:
- GPT partition table
- unencrypted FAT32 `/boot` partition
- LUKS-encrypted "main data" partition
- ideally secure boot
- potentially LUKS autounlock using TPM 

### Store a new header

```sh
$ i="eui.e8238fa6bf530001001b448b4ddc9578_4ea8f160-0315-4704-a1bd-0bb476652cfd"

# Workaround `root_squash` for warthog shares
$ sudo cryptsetup luksHeaderBackup --header-backup-file="${i}.header" /dev/nvme0n1p2
$ mv "${i}.header" /warthog/backups/luks_headers/

# Store the password too.
$ vim "/warthog/backups/luks_headers/${i}.password" 
```

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

These backups are stored on a drive that's encrypted with ZFS native encryption but not with LUKS: so isn't vulnerable to having a corrupted LUKS header.

The intent is for an unrecoverable failure to **simultaneously** require:
- a boot disk to have a corruption in the LUKS header
- the backup header stored in a ZFS pool to become unreadable due to an uncorrected error

