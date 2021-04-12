# RucoPie

# :warning: Experimental project, not usable yet.

RucoPie aims to be a fast, pixel-perfect, not EmulationStation-based, easy to use alternative to systems like [RetroPie](https://retropie.org.uk/), [Lakka](https://www.lakka.tv/) or [Recalbox](https://www.recalbox.com/). It targets Raspberry Pi 3 and 4 devices, and it was insprired by [RGB-Pi](https://www.rgb-pi.com/) (with a big difference: this is not for CRT TVs, if you like that, please check RGB-Pi instead :smiley:)

## Features

* Independently of your screen's physical resolution, all games will be automatically scaled to fill as much screen area as possible and, at the same time, keep a correct aspect ratio and a [pixel-perfect](https://i.postimg.cc/8P0VhbT2/Super-Mario-Land-World-Rev-A-210331-225028.png) output (options for stretching, bilinear filtering and other tweaks are planned).
* Fast, Open Source, eye-candy, pixel-perfect UI that will work right away in any resolution that is a multiple of 640x360. That said, it should look alright in:
  * HD (1280x720)
  * Full HD (1920x1080)
  * WQHD (2560x1440, Raspberry Pi 4 only)
  * 4K (3840x2160, Raspberry Pi 4 only)

If you have a screen with a resolution that isn't a multiple of 640x360 (1366x768, for instance), all games will still look pixel-perfect, but you won't get a pixel-perfect UI right away. Workarounds for this are also planned in the form of "custom resolutions". Here's some screenshots for the current state of the UI, lots of things are still missing:

![](https://i.postimg.cc/fTR8nRyc/screenshot-1618111911.png)
![](https://i.postimg.cc/7YtmxrJp/screenshot-1618111918.png)
![](https://i.postimg.cc/x1kg8pKq/screenshot-1618111927.png)

```bash
curl -s https://raw.githubusercontent.com/tavuntu/rucopie-bkp/main/setup.sh | bash -s
```


Things to do/fix:

* Integer coordinates for background to behave smootly
* filesystem speed (add LFS)  (done)
* Persist optimal resolutions for cores and general preferences (done)
* Wireless conexion screen
* More video options (in progress)
* Add more themes
* Add animated boot screen
* Add music
* Add no copyright roms
* Bluetooth joystick support
* Locale/Country settings
* Skip button while mapping joystick for UI
* Change the terminal banner
* Add Favorites
* Recently played
* All games
