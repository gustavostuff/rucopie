# RucoPie

## :warning: Experimental project in really early stages, not really usable yet.

RucoPie aims to be an easy to use alternative to systems like [RetroPie](https://retropie.org.uk/), [Lakka](https://www.lakka.tv/) or [Recalbox](https://www.recalbox.com/). It targets Raspberry Pi 3 and 4 devices, and it was insprired by [RGB-Pi](https://www.rgb-pi.com/)... with a big difference: this is not for CRT TVs (yet?), if you like that, please go check RGB-Pi instead :smiley:

## Features
(not all of these are yet implemented)

* Fast environment, it boots on [DietPi](https://dietpi.com/) (highly optimized Raspbian)
* For the UI:
    * Thread-based (helps with performance as well)
    * Pixel-perfect in any resolution that is a multiple of 640x360:
      * HD (1280x720)
      * Full HD (1920x1080)
      * WQHD (2560x1440, Raspberry Pi 4 only)
      * 4K (3840x2160, Raspberry Pi 4 only)
    * Highly customizable
    * A theme system you've never seen (highly customizable as well)
* Automatically scaled, pixel perfect games (RetroArch) in any resolution
* Extra video options for bilinear, stretching and other tweaks.

![](https://i.postimg.cc/76RKYsSv/screenshot-1618112860.png)
![](https://i.postimg.cc/qgVQ2Nmj/screenshot-1618112871.png)
![](https://i.postimg.cc/PrzcNmrZ/screenshot-1618183351.png)
![](https://i.postimg.cc/SNhpF4pb/screenshot-1618117083.png)

## How to try this out:

* Install DietPi for Raspberry Pi and start the system
* Connect to the internet and enable Onboard Wifi
* Enable automatic boot
* Set OpenSSH as default SSH server with ```dietpi-software``` (this is for roms transferring)
* Run the following script and follow steps

```bash
curl -s https://raw.githubusercontent.com/tavuntu/rucopie-bkp/main/setup.sh | bash -s
```

* Reboot, and it should be ready to go

## Things to do/fix:

* Integer coordinates for background to behave smootly
* filesystem speed (add LFS)  (done)
* Persist optimal resolutions for cores and general preferences (done)
* Support joysticks via USB (done-ish)
* Wireless internet conexion screen
* More video options (in progress)
* Add more themes
* Add animated boot screen
* Add background music manager
* Add no-copyright roms
* Bluetooth joystick support
* Locale/Country settings
* Skip button while mapping joystick for UI
* Change the terminal banner
* Add Favorites
* Recently played
* All games
* Other things not in this list
