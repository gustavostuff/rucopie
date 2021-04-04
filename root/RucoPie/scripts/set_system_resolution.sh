#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"

core=$1
w=$2
h=$3
file=/opt/retropie/configs/all/retroarch/cores/"$core".cfg
colorEcho "green" "Setting ${w}x${h} on core ${core}, for config file ${file}"

# set these two lines just in case, but probably not needed
sed -i -e "s/custom_viewport_x =.*/custom_viewport_x = \"0\"/g" "$file"
sed -i -e "s/custom_viewport_y =.*/custom_viewport_y = \"0\"/g" "$file"

sed -i -e "s/custom_viewport_width =.*/custom_viewport_width = \"${w}\"/g" "$file"
sed -i -e "s/custom_viewport_height =.*/custom_viewport_height = \"${h}\"/g" "$file"
