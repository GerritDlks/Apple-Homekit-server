# 1
# Download raspbian (jessie) lite and flash to a SD card and power pi
# https://downloads.raspberrypi.org/raspbian_lite_latest

# ------------------------------------------------------------------------------

# 2
# change pi's password
sudo passwd pi

# ------------------------------------------------------------------------------

# 3
# Expand file system, enable SSH and change keyboard layout
sudo raspi-config

# ------------------------------------------------------------------------------

# 4
# Connect to your WiFi (or ethernet) and give your pi a static IP

# edit WPA supplicant configuration file
Sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

# Content will be something like this
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="ssid_name_here"
        psk="password_here"
        id_str="kevin_home"
}

# edit network interfaces file:
sudo nano /etc/network/interfaces

# Content will be something like this (for WiFi)
# For ethernet: remove line 43 and change 'wlan0' to 'eth0' on line 48
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
auto wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf

iface kevin_home inet static
address 192.168.1.200
netmask 255.255.255.0
gateway 192.168.1.1

iface default inet dhcp

# reboot
sudo reboot
