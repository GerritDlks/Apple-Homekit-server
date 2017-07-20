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
}

# edit dhcpcd.conf file:
sudo nano /etc/dhcpcd.conf

# Append your settings to the end of the file ans save it
# For ethernet: change 'wlan0' to 'eth0' on line 45
interface eth0
static ip_address=192.168.1.200
static routers=192.168.1.1
static domain_name_servers=192.168.1.1


# reboot
sudo reboot
