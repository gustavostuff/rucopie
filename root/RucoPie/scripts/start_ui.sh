#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"

function start () {
  colorEcho "green" "$separator"

  if pgrep -x "love" > /dev/null
  then
    colorEcho "green" "RucoPie UI is currently running."
    return 0
  fi

  if pgrep -x "retroarch" > /dev/null
  then
    colorEcho "green" "Retroarch is currently running."
    return 0
  fi

  logs="/root/nohup.out"
  [ -e "$logs" ] && rm "$logs"
  colorEcho "green" "Starting RucoPie UI..."
  nohup love /root/RucoPie/ui > ~/ui.log &
  colorEcho "green" "$separator"
}

start
