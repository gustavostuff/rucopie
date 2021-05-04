# RucoPie

:warning: This is in early development stages

RucoPie is a sweet, easy to use alternative to systems like [RetroPie](https://retropie.org.uk/), [Lakka](https://www.lakka.tv/) or [Recalbox](https://www.recalbox.com/). It targets Raspberry Pi 3 and 4 devices to be used via HDMI.

## Features

* Fast boot, built on top of [DietPi](https://dietpi.com/)
* Support for pretty much every Libretro emulator
* Automatically scaled, pixel perfect games in any resolution
* Built-in Multimedia Player
* Multi-Language: :us: :es: :fr: :de:
* Flexible theme system
  * Multi-layer, dynamic backgrounds
  * Per-theme icons
  * Per-theme sounds/music
  * Other tweaks for opacity, shadows and sizing
* Color palette editor
* Heavy operations (file reading/writing, large data processing) are asynchronous
* Pixel-perfect UI in any resolution that is a multiple of 640x360, such as:  
  * Standard HD (1280x720)
  * Full HD (1920x1080)
  * WQHD (2560x1440)
  * 4K UHD (3840x2160)
* Extra video options for bilinear, stretching and other tricks
* Audio equalizer with Winamp's presets
* Vertical mode
* 180° mode
* WiFi setup screen (non-terminal based)

![](https://i.postimg.cc/NGk8Yjp8/screenshot-1620085835.png)
![](https://i.postimg.cc/28jQ5NKs/screenshot-1620085841.png)
![](https://i.postimg.cc/Wb9MFfRh/screenshot-1620085851.png)
![](https://i.postimg.cc/sgv5p9yK/screenshot-1620085931.png)

## How to try this out:

* Install DietPi on your Raspberry Pi and start the system
* Connect to the Internet and enable Onboard Wifi
* Enable automatic boot
* Set OpenSSH as default SSH server with ```dietpi-software``` (this is for roms transferring)
* Run the following script and follow the steps

```bash
curl -s https://raw.githubusercontent.com/tavuntu/rucopie-bkp/main/setup.sh | bash -s
```

* Reboot, and it should be ready to go!

## Things to do/fix:

* Integer coordinates for background to behave smootly
* filesystem speed (add LFS)  (done)
* Persist optimal resolutions for cores and general preferences (done)
* Support joysticks via USB (done-ish)
* Wireless internet conexion screen (in progress)
* More video options (in progress)
* Add more themes
* Add animated boot screen
* Add background music manager
* Add audio equalizer with profiles, if possible
* Add no-copyright roms
* Bluetooth joystick support
* Locale/Country settings
* Skip button while mapping joystick for UI
* Change the terminal banner
* Add Favorites
* Recently played
* All games
* Vertical mode
* Add other languages (done, ES and FR)
* Multimedia player
* Game scrapping for listing
* Other things not in this list

---

## Notes
* RucoPie was inspired by [RGB-Pi](https://www.rgb-pi.com/)
* Not everything described in here is implemented yet
