#!/bin/bash

logs="/root/nohup.out"
[ -e "$logs" ] && rm "$logs"

nohup love /root/RucoPie/ui > ~/ui.log &
