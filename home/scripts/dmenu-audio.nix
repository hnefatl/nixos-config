{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "dmenu-audio";
  text =
    let
      pactl = "${pkgs.pulseaudio}/bin/pactl";
      fuzzel = lib.getExe pkgs.fuzzel;
      pw-dump = "${pkgs.pipewire}/bin/pw-dump";
      jq = lib.getExe pkgs.jq;
    in
    ''
      sinkname=$(${pw-dump} | ${jq} -r '.[] | select(.info.props."media.class" == "Audio/Sink") | [.info.props."node.name", .info.props."node.description"] | join("\t")' | sort -u -k2 | ${fuzzel} --dmenu --with-nth=2 --accept-nth=1 --lines=5)

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
