#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"
core="$1"
configname="$2"
value="$3"

corefile=/opt/retropie/configs/all/retroarch/cores/"$core".cfg
colorEcho "green" "Setting config ${configname} = ${value} on core ${core}, for config file ${corefile}"

sed -i -e "s/${configname} =.*/${configname} = \"${value}\"/g" "$corefile"
