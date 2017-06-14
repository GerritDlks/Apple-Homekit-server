# The test assecory is the onboard LED of the raspberry pi

# Install the accessory
cd /home/pi/HAP-NodeJS/accessories/
sudo rm -rf Light_accessory.js
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Home-on-RPi/master/Accessories/Light_accessory-OnBoardLED.js

# Install the script
sudo mkdir /home/pi/HAP-NodeJS/python
cd /home/pi/HAP-NodeJS/python
sudo wget https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Home-on-RPi/master/Python%20scripts/onboard-LED.py
