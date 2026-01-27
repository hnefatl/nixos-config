#!/usr/bin/env bash

pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused) | .pid')
indices=$(pactl -f json list sink-inputs | jq ".[] | select(.properties.\"application.process.id\" == \"${pid}\") | .index")

output=""
for index in ${indices} ; do
    pactl set-sink-input-mute "${index}" toggle
    output=$(pactl get-sink-input-mute "${index}")
done

id_file="/tmp/mute-application-${pid}"
existing_id=()
if [[ -f "${id_file}" ]] ; then
    existing_id=(-r "$(< "${id_file}")")
fi
if [[ "${output}" =~ "yes" ]] ; then
    urgency=(-u critical)
    timeout=(-t 0)
    body="Muted"
else
    urgency=(-u normal)
    timeout=(-t 1000)
    body="Unmuted"
fi
exec notify-send "${urgency[@]}" "${timeout[@]}" "${existing_id[@]}" -p "Application ${pid}" "${body}" > "${id_file}"
