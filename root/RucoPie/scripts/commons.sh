#!/bin/bash

red="\033[0;31m"
green="\033[0;32m"
default="\033[0m"

separator="-------------------------------------------------------------------"

function color_echo() {
  colorcode=""
  case $1 in
    red)
      colorcode="$red"
      ;;
    green)
      colorcode="$green"
      ;;
    *)
      echo "Error: Color code $1 is not valid."
      return 1
  esac

  echo -e "${colorcode} $2 ${default}"
}
