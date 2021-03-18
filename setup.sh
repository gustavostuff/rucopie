
#!/bin/bash

: '
Copyright 2021 Gustavo Lara
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'

red="\033[0;31m"
green="\033[0;32m"
default="\033[0m"

function separator () {
  echo "******************************************************************"
}

cd ~

separator
echo "Installing RetroPie dependencies..."
/boot/dietpi/dietpi-software install 5 6 16 17

separator
echo -e "${red}Executing RetroPie Setup (answer yes to user ownership messages and then exit)...${default}"
/usr/bin/git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
./retropie_setup.sh

cd ~
separator
echo "Installing now retroarch..."
~/RetroPie-Setup/retropie_packages.sh retroarch

separator
echo "Installing now lr-fceumm..."
~/RetroPie-Setup/retropie_packages.sh lr-fceumm

separator
echo "Installing now lr-gambatte..."
~/RetroPie-Setup/retropie_packages.sh lr-gambatte

separator
echo "Installing now lr-fbneo..."
~/RetroPie-Setup/retropie_packages.sh lr-fbneo

separator
echo "Installing now lr-snes9x..."
~/RetroPie-Setup/retropie_packages.sh lr-snes9x

separator
echo "Installing now love..."
~/RetroPie-Setup/retropie_packages.sh love

separator
echo "Installing now splashscreen manager..."
~/RetroPie-Setup/retropie_packages.sh splashscreen
~/RetroPie-Setup/retropie_packages.sh splashscreens

/usr/bin/git clone https://github.com/tavuntu/rucopie-bkp
cd rucopie-bkp
separator
echo "Installing config files..."
cp -r * /
cd ..
rm -rf rucopie-bkp
rm setup.sh

separator
separator
echo "                     DONE!"
separator
separator
