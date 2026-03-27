#!/usr/bin/env bash

if [[ "$1" == "" ]] ; then
    echo "Usage: dim_screen.sh <duration>"
    exit 1
fi

readonly STEPS=500
sleep_duration=$(bc <<< "scale=2; $1/$STEPS")

delta_brightness=$(($(brightnessctl get) / STEPS))
for ((i=0; i<="$STEPS"; i++)) ; do
    brightnessctl --quiet set -d '*' "${delta_brightness}-"
    sleep "$sleep_duration"
done
