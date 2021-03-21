#!/bin/bash

if pgrep -x "love" > /dev/null
then
   echo "RucoPie UI is already running, ignoring request."
else
  logs="/root/nohup.out"
  [ -e "$logs" ] && rm "$logs"
  echo "Starting RucoPie UI..."
  nohup love /root/RucoPie/ui > ~/ui.log &
fi
