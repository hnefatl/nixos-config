#!/usr/bin/env bash

# If the script is invoked and we're already doing a screencapture thing, terminate the original one.
if [[ $(pgrep -x slurp) ]] ; then
    exec pkill -x slurp
fi
if [[ $(pgrep -x wf-recorder) ]] ; then
    # SIGINT gracefully stops recording.
    pkill -SIGINT -x wf-recorder
    exec notify-send 'Recording complete' 'Saved to /tmp/recording.mp4'
fi

if [[ "$1" == "printscreen" ]] ; then
    exec grimshot --notify --cursor copy anything
elif [[ "$1" == "delay_printscreen" ]] ; then
    delay="$(printf '3\n5\n' | fuzzel --dmenu -p 'Delay:')"
    exec grimshot --notify --cursor --wait "$delay" copy anything
elif [[ "$1" == "record" ]] ; then
    area="$(slurp -d)"
    notify-send -t 2000 'Recording started' 'Hit printscreen to stop.'
    exec wf-recorder -g "$area" -f /tmp/recording.mp4 -y
else
    echo "Unknown command: '$1'"
    exit 1
fi

