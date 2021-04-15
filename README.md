# RucoPie

## :warning: This is in early development stages

RucoPie aims to be an easy to use alternative to systems like [RetroPie](https://retropie.org.uk/), [Lakka](https://www.lakka.tv/) or [Recalbox](https://www.recalbox.com/). It targets Raspberry Pi 3 and 4 devices to be used via HDMI.

## Features

* Fast environment, built on top of [DietPi](https://dietpi.com/) (highly optimized Raspbian)
* For the UI:
    * Thread-based
    * Pixel-perfect in any resolution that is a multiple of 640x360, such as:  
      * [Standard HD](https://en.wikipedia.org/wiki/720p)
      * [Full HD](https://en.wikipedia.org/wiki/1080p)
      * [Quad HD](https://en.wikipedia.org/wiki/1440p)
      * [4K UHD](https://en.wikipedia.org/wiki/4K_resolution)
    * Highly customizable
    * Flexible theme system
* Automatically scaled, pixel perfect games (RetroArch) in any resolution
* Extra video options for bilinear, stretching and other tweaks.
* Audio equalizer and custom profiles
* Thumbnail Game States

![](https://i.postimg.cc/2jZrbwH9/screenshot-1618196440.png)
![](https://i.postimg.cc/7YrDg2dH/screenshot-1618196445.png)
![](https://i.postimg.cc/PrbHKqnm/screenshot-1618196453.png)
![](https://i.postimg.cc/PrzcNmrZ/screenshot-1618183351.png)

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
* Add no-copyright roms
* Bluetooth joystick support
* Locale/Country settings
* Skip button while mapping joystick for UI
* Change the terminal banner
* Add Favorites
* Recently played
* All games
* Vertical mode
* Add other languages
* Game states with thumbnaild
* Audio management
* Other things not in this list

---

RucoPie was inspired by [RGB-Pi](https://www.rgb-pi.com/)
