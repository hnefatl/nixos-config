#!/usr/bin/env bash

pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused) | .pid')
indices=$(pactl -f json list sink-inputs | jq ".[] | select(.properties.\"application.process.id\" == \"${pid}\") | .index")

for index in ${indices} ; do
    pactl set-sink-input-mute "${index}" toggle
done
