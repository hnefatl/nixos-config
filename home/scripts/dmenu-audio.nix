{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "dmenu-audio";
  text = let
    pactl = "${pkgs.pulseaudio}/bin/pactl";
    dmenu = "${lib.getExe pkgs.fuzzel} --dmenu";
  in ''
    # Don't use monitor speakers on any machine.
    exclude='HDMI|hdmi'
    sinkname="$(${pactl} list short sinks | grep -vE "$exclude" | awk '{print $2}' | sort | ${dmenu})"

    if [[ -n "$sinkname" ]] ; then
        ${pactl} set-default-sink "$sinkname"
        # Move active sink inputs
        for inputindex in $(${pactl} list short sink-inputs | awk '{print $1}') ; do
            ${pactl} move-sink-input "$inputindex" "$sinkname"
        done
        # Update the volume i3block
        pkill -RTMIN+10 i3blocks
    fi
  '';
}

