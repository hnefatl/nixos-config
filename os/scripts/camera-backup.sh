#!/usr/bin/env bash

set -x

# Connect us to the existing dbus session - this script is automatically run
# from a systemd unit that doesn't know which dbus/window environment to use.
export DBUS_SESSION_BUS_ADDRESS
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

notification_id=$(notify-send --print-id --expire-time=$((60 * 60 * 1000)) "SD card loaded" "Backing up photos...")
if rsync -av /camera/DCIM/100CANON/ /warthog/camera/ ; then
  notify-send --replace-id="${notification_id}" --expire-time=$((3 * 1000)) "SD card loaded" "Photos backed up"
else
  notify-send --replace-id="${notification_id}" --expire-time=$((60 * 60 * 1000)) --urgency=critical "SD card loaded" "Failure backing up photos: $?"
fi
