# Apple Homekit (and PiHole) Server
This is my personal setup on a raspberry pi of mine. It sets up HAP-NodeJS (HomeKit Accessory Server) and, because why not, it also runs a PiHole server. So it combines my love for home automation with Apple devices and my disgust for adds!

# HAP-NodeJS personal setup
I personally use the [HAP-NodeJS](https://github.com/KhaosT/HAP-NodeJS) server to connect a couple of Sonoff devices to my Apple Home setup. This way I can transform my dumb devices and lighting into smart devices and smart lighting.  
Check out below to see how to use and configure a [Sonoff basic](https://www.itead.cc/sonoff-wifi-wireless-switch.html) device to be compatible with HAP!

# PiHole
[PiHole](https://github.com/pi-hole/pi-hole) is a multi-platform (android, iOS, Windows, macOS, Linux, ...) system-wide (no need for special software on your devices) ad-blocker.  
I configured this too on my HAP-NodeJS server, because why not? It's the best ad-blocker out there!



# Install HAP
## Prerequisites
Before you can start your installation of a HAP-NodeJS server, you first need to [preconfigure]() your Raspberry Pi:  

**OS**  
I use [raspbian Jessie Lite](https://downloads.raspberrypi.org/raspbian_lite_latest). The Lite version because we don't need a graphical desktop. If you're on a mac but don't really know how to flash to OS on your SD card, then I can recommend [Etcher](https://etcher.io).  
When you boot your Raspberry Pi, it will have a user named 'pi'

**internet access**  
Preferred way is connecting your Raspberry Pi using ethernet and giving it a fixed IP address.  
If you do not know how to set a fixed IP address using CLI, than you can take a look on how [I did it](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/install%20files/prerequisites.sh#L20).  

**Expand file system, enable SSH access**  
This is necessary if you want to connect to your Pi when it's tucked away somewhere with limited physical access.  
You can do both things using the raspi-config configuration window:  
```bash
sudo raspi-config
```  

Now you can SSH into your Raspberry pi (change IP address with your own static IP address):
```bash
ssh pi@192.168.1.10
```  

**Change password for user 'pi'**
It's recommended to change the default password for the user 'pi' on your raspberry pi.  This can be easily done by using the following command, it will ask you for a new password.  
```bash
sudo passwd pi
```  

## Install script
To install HAP-NodeJS, I created a simple script that will do everything for you. Just execute the following line on your Raspberry Pi, lay back and relax. This can take a while (up to 1 hour, maybe).
```bash
cd && sudo wget https://goo.gl/8oN37T && sudo sh installHAP.sh && rm installHAP.sh
```

When this completes, HAP-NodeJS will be installed and will be running. There will be 2 folders that you'll update regulary when setting up your Homekit devices:
- cd /home/pi/HAP-NodeJS/accessories
- cd /home/pi/HAP-NodeJS/python

The accessories folder will contain all Homekit accessories (e.g. power points, lighting, ...). The accessory files must all end on 'accessory.js'.  
The python folder will contain all scripts that you want to execute when the state of a certain accessory changes (configurable in the accessories).

## Test installation - Pi's onboard LED as light accessory
To test your installation, you can configure the onboard LED of your Raspberry Pi as a light accessory. This is also a great way to learn how to use the [example accessories](https://github.com/KhaosT/HAP-NodeJS/tree/master/accessories).  
To install the LED accessory, execute the following command:
```bash
cd && sudo wget https://goo.gl/JGdV8Z  && sudo sh install_onboardLED_accessorry.sh && rm install_onboardLED_accessorry.sh && restartHAP
```  
This will install 2 files:
- /home/pi/HAP-NodeJS/accessories/[Light_OnBoardLED_accessory.js](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_OnBoardLED_accessory.js)
- /home/pi/HAP-NodeJS/python/[onboard-LED.py](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/python%20scripts/onboard-LED.py)

In the accessory file, you can see that you must change some variables (if you start from the [demo file](https://github.com/KhaosT/HAP-NodeJS/blob/master/accessories/Light_accessory.js)), located on [line 14-19](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_OnBoardLED_accessory.js#L14). The comments in the code explain the meaning of each variable.  
Next you might want to change what script gets executed when the light changes of state. [Line 30](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_OnBoardLED_accessory.js#L30) shows the script that will be executed. Change to your needs.  
The script that will toggle the LED is located in the python folder (as shown on [Line 30](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_OnBoardLED_accessory.js#L30) in the accessory file).  

Now you're able to create a light accessory. If you want to create a second light accessory file, just duplicate the Light_OnBoardLED_accessory.js file, change the name, and change line 14-19 and 30.  

To remove the onboard LED accessory, execute the following command:
```bash
rm /home/pi/HAP-NodeJS/accessories/Light_OnBoardLED_accessory.js /home/pi/HAP-NodeJS/python/onboard-LED.py && echo mmc0 | sudo tee /sys/class/leds/led0/trigger && restartHAP
```

To remove any other accessory, You can just remove the accessory.js file (and, optionally, the python script). Be sure to always restart the HAP-NodeJS server by executing the following custom command:
```bash
restartHAP
```

## Add light accessories
I included 2 other files:
- A simple [light accessory file](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_GPIO_accessory.js) that toggles a GPIO pin (e.g. to toggle a LED that you've connected).
- The [python script](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/python%20scripts/set-GPIO.py) to toggle the GPIO pin.

To use these, just copy the files to the correct folder, change the correct lines in the accessory file, and extra: change [line 13](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/Light_GPIO_accessory.js#L13) of the accessory file with the GPIO number of the output that you want to control.

 Be sure to always restart the HAP-NodeJS server after changing, removing or adding accessories, by executing the following custom command:
```bash
restartHAP
```

# Sonoff devices with HAP-NodeJS server

## What you'll need
- programmer
- Sonoff device

## Install Sonoff HAP-NodeJS packages
TODO

## Flash Sonoff
TODO

## Configure accessory
TODO

# Pi-Hole

## Install
```bash
curl -sSL https://install.pi-hole.net | bash
```  
During your installation, choose the openDNS servers (or the Google ones) and select the interface that you want to use (WiFi or Ethernet).  

## Change password
To change your password, use:
```bash
pihole -a -p newpasswordhere
```  

## Web interface
To access the web interface, enter the fixed IP address of your Raspberry Pi into your browser and then add '/admin' to it. E.g.:
```bash
192.168.1.10/admin
```  

## Configure your devices
To enable the ad blocking, your devices must use your Raspberry Pi's static IP address as DNS server. You can set these manually, configure your router to broadcast these settings, or disable DHCP on your router and use the DHCP server of PiHole.
