#!/bin/bash

failed_status=1

core=""
case $1 in
  nes)
    core="fceumm"
    ;;
  snes)
    core="snes9x"
    ;;
  gb)
    core="gambatte"
    ;;
  neogeo)
    core="fbneo"
    ;;
  *)
    echo "Error: System $1 is not valid."
esac

if [ -z $core ]; then
  return $failed_status
fi

## full game path:
path="$2"
echo "Executing retroarch with: core = $core, rom = $path"

/opt/retropie/emulators/retroarch/bin/retroarch -L \
/opt/retropie/libretrocores/lr-"$core"/"$core"_libretro.so \
--config ~/.config/retroarch/cores/"$core".cfg "$path" \
/

