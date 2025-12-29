#!/usr/bin/env bash

source=$(pactl get-default-source)
description=$(pactl -f json list sources | jq -r ".[] | select(.name == \"${source}\") | .properties.\"device.description\"")

pactl set-source-mute "${source}" toggle
exec notify-send "${description}" "$(pactl get-source-mute "${source}")"
