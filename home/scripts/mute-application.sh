#!/usr/bin/env bash

pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused) | .pid')
indices=$(pactl -f json list sink-inputs | jq ".[] | select(.properties.\"application.process.id\" == \"${pid}\") | .index")

output=""
for index in ${indices} ; do
    pactl set-sink-input-mute "${index}" toggle
    output=$(pactl get-sink-input-mute "${index}")
done
exec notify-send "Application ${pid}" "${output}"
