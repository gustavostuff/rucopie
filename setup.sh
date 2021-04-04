
#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"
cd ~

colorEcho "green" "$separator"
echo "Installing RetroPie dependencies..."
/boot/dietpi/dietpi-software install 5 6 16 17

colorEcho "green" "$separator"
echo ''
echo -e "${green}Executing RetroPie Setup (answer yes to user ownership messages and then exit)...${default}"
echo ''

/usr/bin/git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
./retropie_setup.sh

cd ~
colorEcho "green" "$separator"
echo -e "${green}Installing required packages...${default}"
declare -a pkgs=("retroarch" "love" "splashscreen" "lr-gambatte" "lr-fceumm" "lr-snes9x" "lr-fbneo" "lr-stella2014")
for pkg in "${pkgs[@]}"
do
  colorEcho "green" "$separator"
  echo "Installing dependencies for $pkg..."
  ~/RetroPie-Setup/retropie_packages.sh $pkg depends
  echo "Installing now $pkg..."
  ~/RetroPie-Setup/retropie_packages.sh $pkg install_bin
done

/usr/bin/git clone https://github.com/tavuntu/rucopie-bkp
cd rucopie-bkp
colorEcho "green" "$separator"
echo "Installing config files..."

cp -r boot/ /
cp -r opt/ /
cp -r root/ /
cp -r var/ /
chmod +x ~/RucoPie/scripts/*

echo "Creating global link for love..."
cd ..
ln -s /opt/retropie/ports/love/bin/love /usr/bin/

echo "Installing extra Lua stuff..."
apt-get install luarocks
luarocks install luafilesystem

colorEcho "green" "$separator"
colorEcho "green" "Done!"
colorEcho "green" "$separator"
