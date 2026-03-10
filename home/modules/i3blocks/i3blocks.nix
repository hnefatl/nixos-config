{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  # Refer to the files downloaded from https://github.com/vivien/i3blocks-contrib
  contrib_script = name: "${inputs.i3blocks-contrib}/${name}/${name}";
in
{
  # Dependencies of the scripts.
  home.packages = with pkgs; [
    i3blocks
    acpi
    playerctl
    alsa-utils
    pulseaudio
    iw
    curl
  ];

  # The home-manager module for i3blocks configs don't allow setting global options and make ordering tricky.
  # Writing the file explicitly is easier.
  xdg.configFile."i3blocks/config".text = ''
    separator_block_width=15
    markup=pango
  
    [spotify]
    command=${./spotify.sh}
    interval=3
    separator=true
    signal=11
    
    [volume]
    command=${contrib_script "volume"}
    label=VOL 
    instance=Master
    interval=10
    signal=10
    
    [memory]
    command=${contrib_script "memory"}
    label=MEM 
    separator=false
    interval=30
    PERCENT=false
    
    [memory]
    command=${contrib_script "memory"}
    label=SWAP 
    instance=swap
    separator=false
    interval=30
    PERCENT=false
    
    [disk]
    command=${contrib_script "disk"}
    label=HOME 
    interval=30
    
    [iface]
    command=${contrib_script "iface"}
    color=#00FF00
    interval=10
    separator=false
    
    [wifi]
    command=${contrib_script "wifi"}
    interval=10
    separator=false
    
    [cpu_usage]
    command=${contrib_script "cpu_usage"}
    label=CPU 
    interval=10
    min_width=CPU 100%
    DECIMALS=0
    COLOR_NORMAL="#FFFFFF"
    
    [battery]
    command=${contrib_script "battery"}
    label=BAT 
    interval=30
    
    [time]
    command=date '+%Y-%m-%d %H:%M:%S'
    interval=5
  '';
}
