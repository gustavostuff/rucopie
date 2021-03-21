#!/bin/bash

core=$1
w=$2
h=$3
file=/opt/retropie/configs/all/retroarch/cores/"$core".cfg
echo "Setting ${w}x${h} on core ${core}, for config file ${file}"

sed -i -e "s/custom_viewport_x =.*/custom_viewport_x = \"0\"/g" "$file"
sed -i -e "s/custom_viewport_y =.*/custom_viewport_y = \"0\"/g" "$file"

sed -i -e "s/custom_viewport_width =.*/custom_viewport_width = \"${w}\"/g" "$file"
sed -i -e "s/custom_viewport_height =.*/custom_viewport_height = \"${h}\"/g" "$file"
