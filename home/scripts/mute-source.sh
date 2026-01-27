#!/usr/bin/env bash

source=$(pactl get-default-source)
description=$(pactl -f json list sources | jq -r ".[] | select(.name == \"${source}\") | .properties.\"device.description\"")

pactl set-source-mute "${source}" toggle

id_file=/tmp/mute-source-id
existing_id=()
if [[ -f "${id_file}" ]] ; then
    existing_id=(-r "$(< "${id_file}")")
fi
if [[ "$(pactl get-source-mute "${source}")" =~ "yes" ]] ; then
    urgency=(-u critical)
    timeout=(-t 0)
    body="Muted"
else
    urgency=(-u normal)
    timeout=(-t 1000)
    body="Unmuted"
fi
exec notify-send "${urgency[@]}" "${timeout[@]}" "${existing_id[@]}" -p "${description}" "${body}" > "${id_file}"
