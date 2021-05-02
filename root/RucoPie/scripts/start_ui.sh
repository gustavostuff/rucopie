#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"

function start () {
  color_echo "green" "$separator"

  if pgrep -x "love" > /dev/null
  then
    color_echo "green" "RucoPie UI is currently running."
    return 0
  fi

  if pgrep -x "retroarch" > /dev/null
  then
    color_echo "green" "Retroarch is currently running."
    return 0
  fi

  logs="/root/nohup.out"
  [ -e "$logs" ] && rm "$logs"
  color_echo "green" "Starting RucoPie UI..."
  nohup love /root/RucoPie/ui > ~/ui.log &
  color_echo "green" "$separator"
}

start
