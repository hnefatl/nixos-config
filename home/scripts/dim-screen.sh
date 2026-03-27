#!/usr/bin/env bash

if [[ "$1" == "" ]] ; then
    echo "Usage: dim_screen.sh <duration>"
    exit 1
fi

# Use bash builtin sleep, not an external program. For some reason the extra
# subprocess causes swayidle to terminate the command without sleeping.
enable sleep

readonly STEPS=500
sleep_duration=$(bc <<< "scale=2; $1/$STEPS")

delta_brightness=$(($(brightnessctl get) / STEPS))
for ((i=0; i<="$STEPS"; i++)) ; do
    brightnessctl --quiet set -d '*' "${delta_brightness}-"
    sleep "$sleep_duration"
done
