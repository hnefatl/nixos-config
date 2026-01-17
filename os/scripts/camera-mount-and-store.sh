#!/usr/bin/env bash

set -x

ak() {
    sudo -u keith "$@"
}
notify() {
  ak DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u keith)/bus" notify-send "$@"
}

if ! mountpoint -q /camera ; then
  mount /camera
fi

notification_id=$(notify --print-id --expire-time=$((60 * 60 * 1000)) "SD card loaded" "Backing up photos...")
if ak rsync -av /camera/DCIM/100CANON/ /warthog/camera/ ; then
  notify --replace-id="${notification_id}" --expire-time=$((3 * 1000)) "SD card loaded" "Photos backed up"
else
  notify --replace-id="${notification_id}" --expire-time=$((60 * 60 * 1000)) --urgency=critical "SD card loaded" "Failure backing up photos: $?"
fi
