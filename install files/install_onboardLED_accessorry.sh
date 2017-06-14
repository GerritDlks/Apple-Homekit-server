# The test assecory is the onboard LED of the raspberry pi

# Install the accessory
cd /home/pi/HAP-NodeJS/accessories/
sudo rm -rf Light_accessory.js
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/accessories/Light_OnBoardLED_accessory.js

# Install the script
sudo mkdir /home/pi/HAP-NodeJS/python
cd /home/pi/HAP-NodeJS/python
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/python%20scripts/onboard-LED.py
