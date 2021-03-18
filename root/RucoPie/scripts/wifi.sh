#!/bin/sh
## A simple `wifi` command for Debian that will connect you to a WPA2 WiFi network
## Based on gist.github.com/rjsteinert
## usage:
## sudo ./wifi.sh <ssid> <pass>

ifdown wlan0

# build the interfaces file that will point to the file that holds our configuration
rm /etc/network/interfaces
touch /etc/network/interfaces
echo "auto lo
iface lo inet loopback
iface eth0 inet dhcp
allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp" >> /etc/network/interfaces

# build the supplicant file that holds our configuration
rm /etc/wpa_supplicant/wpa_supplicant.conf
touch /etc/wpa_supplicant/wpa_supplicant.conf
echo 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'update_config=1' >> /etc/wpa_supplicant/wpa_supplicant.conf

wpa_passphrase "$1" "$2" >> /etc/wpa_supplicant/wpa_supplicant.conf
ifup wlan0
