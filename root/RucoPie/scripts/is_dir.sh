#!/bin/bash

item="$1"

echo "    verifying >>> $item"
if [[ -d $item ]]; then
  echo "file"
elif [[ -f $item ]]; then
  echo "directory"
else
  echo "invalid"
fi
