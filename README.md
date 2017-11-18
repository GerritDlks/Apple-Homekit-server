# Apple Homekit Server
It sets up HAP-NodeJS (HomeKit Accessory Server) for Sonoff switches and togling the Raspberry Pi's GPIO pins.

# TL;DR
On a clean Raspberry Pi with a fixed IP, issue the following command to install the server:
```bash
curl -sSL https://goo.gl/8oN37T | bash
```
Then install an accessory (Sonoff or GPIO pin) using the following command:
```bash
accessoryInstaller
```

***
***
***
***
***

# HAP-NodeJS personal setup
I personally use the [HAP-NodeJS](https://github.com/KhaosT/HAP-NodeJS) server to connect a couple of Sonoff devices to my Apple Home setup. This way I can transform my dumb devices and lighting into smart devices and smart lighting.  
Check out below to see how to use and configure a [Sonoff basic](https://www.itead.cc/sonoff-wifi-wireless-switch.html) device to be compatible with HAP!


# Table of Contents
- [Install HAP](#install-hap)
    - [Prerequisites](#prerequisites)
    - [Install script](#install-script)
    - [Test installation](#test-installation---pis-onboard-led-as-light-accessory)
    - [Add light accessories](#add-light-accessories)
- [Accessory installer](#accessory-installer) (very usefull)
- [Sonoff](#sonoff-devices-with-hap-nodejs-server)
    - [What you'll need](#what-youll-need)
    - [Flash Sonoff](#flash-sonoff)
    - [Install Sonoff HAP-NodeJS packages](#install-sonoff-hap-nodejs-packages)
    - [Configure Sonoff Basic accessory](#configure-sonoff-basic-accessory)




# Install HAP
## Prerequisites
Before you can start your installation of a HAP-NodeJS server, you first need to [preconfigure](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/install%20files/prerequisites.sh) your Raspberry Pi:  

#### OS
I use [raspbian Jessie Lite](https://downloads.raspberrypi.org/raspbian_lite_latest). The Lite version because we don't need a graphical desktop. If you're on a mac but don't really know how to flash to OS on your SD card, then I can recommend [Etcher](https://etcher.io).  
When you boot your Raspberry Pi, it will have a user named 'pi'

#### internet access  
Preferred way is connecting your Raspberry Pi using ethernet and giving it a fixed IP address.  
If you do not know how to set a fixed IP address using CLI, than you can take a look on how [I did it](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/install%20files/prerequisites.sh#L20).  

#### Expand file system, enable SSH access  
This is necessary if you want to connect to your Pi when it's tucked away somewhere with limited physical access.  
You can do both things using the raspi-config configuration window:  
```bash
sudo raspi-config
```  

Now you can SSH into your Raspberry pi (change IP address with your own static IP address):
```bash
ssh pi@192.168.1.10
```  

#### Change password for user 'pi'
It's recommended to change the default password for the user 'pi' on your raspberry pi.  This can be easily done by using the following command, it will ask you for a new password.  
```bash
sudo passwd pi
```  

## Install script
To install HAP-NodeJS, I created a simple script that will do everything for you. Just execute the following line on your Raspberry Pi, lay back and relax. This can take a while (up to 1 hour, maybe even longer...).
```bash
curl -sSL https://goo.gl/8oN37T | bash
```
*cURLing and Piping To Bash can be dangerous, if you do not trust this, I recommend you to download the file with 'wget', check its content and then run the installer yourself.*

When this completes, HAP-NodeJS will be installed and will be running. There will be 2 folders that you'll update regulary when setting up your Homekit devices:
- cd /home/pi/HAP-NodeJS/accessories
- cd /home/pi/HAP-NodeJS/python

The accessories folder will contain all Homekit accessories (e.g. power points, lighting, ...). The accessory files must all end on 'accessory.js'.  
The python folder will contain all scripts that you want to execute when the state of a certain accessory changes (configurable in the accessories).

## Test installation - Pi's onboard LED as light accessory
To test your installation, you can configure the onboard LED of your Raspberry Pi as a light accessory. This is also a great way to learn how to use the [example accessories](https://github.com/KhaosT/HAP-NodeJS/tree/master/accessories).  
To install the LED accessory, execute the following command:
```bash
curl -sSL https://goo.gl/JGdV8Z  | bash
```
*cURLing and Piping To Bash can be dangerous, if you do not trust this, I recommend you to download the file with 'wget', check its content and then run the installer yourself.*  

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

# Accessory installer

To add a device easily, without having to change source-code, copying files, etc, I have added an installer that guides you through the installation of everything. This installer is able to create, add and configure 2 accessories:
- An accessory that toggles a GPIO pin of the raspberry Pi.
- A Sonoff switch accessory

To run the installer, use the following command:
```bash
accessoryInstaller
```

The installer should be pretty clear, but I want to give you one extra tip:  
Choose a good name for the accessory (e.g. 'small kitchen lights in the left corner' instead of 'lights'). This will ease your life when removing accessories later.

# Sonoff devices with HAP-NodeJS server

## What you'll need
For this, you'll need to flash the Sonoff device with a custom firmware. The programmer that you'll need is a USB to TTL Serial Adapter. I bought mine on [eBay](http://www.benl.ebay.be/itm/262812320376?_trksid=p2057872.m2749.l2649&ssPageName=STRK%3AMEBIDX%3AIT) for about 5 euros.

## Flash Sonoff

#### Sonoff Tasmota FW
To use the Sonoff device, you'll have to flash a [custom firmware](https://github.com/arendst/Sonoff-Tasmota) that provides the Sonoff device with Web, MQTT and OTA functions. To download the necessary files, you can [click here](https://github.com/arendst/Sonoff-Tasmota/archive/master.zip). Be sure to unzip these files and store them somewhere you can find them (I just kept them in my Downloads folder).   

#### Atom with PlatformIO IDE
Next you'll need to install [Atom](https://atom.io). This is my default text editor on my mac, and I really can recommend it. The advantage of Atom is the ability to install certain packages that extend functionality. We are going to use this ability and we have to install the plugin [PlatformIO IDE](http://platformio.org/get-started/ide?install=atom). With this plugin we'll be able to upload our code the the Sonoff device and start a serial monitor.  
The installation can take a few minutes. Be sure to restart atom when you're finished with the installation.  
After restarting Atom, you'll be able to create a PlatformIO account, but you can skip this.  

#### Configure Tasmota FW  
In Atom go to 'PlatformIO > Open project folder' and select the folder of the FW that you've downloaded. Normally the name of the folder will be 'Sonoff-Tasmota-master'.  
The tree view of the project files will appear on the left side of Atom. Unfold the folder 'sonoff' and open the file 'user_config.h'.  

In 'user_config.h' you need to edit line 42 and 43. These lines define 'STA_SSID1' and 'STA_PASS1' which is respectively the SSID of your network (wireless network name) and your WiFi Password. Optionally, you can edit line 44 and 45 too, these lines configure a backup wireless network (if available).  
You're free to change other settings in this file, the file itself has many comments so everything should be clear. I personally chose to give the device a fixed IP so that all my Sonoff devices are in the same range of my network.  

Once you're done, go to 'File -> Save' to save the 'user_config.h' file.  

#### Connect the programmer to your Sonoff Device  
To connect your programmer to the Sonoff device, you'll have to solder a header on the Sonoff device. There are enough tutorials to find online about how to do this. In the end, your connection between the programmer and the Sonoff switch will be as following:  

|  SONOFF J1  |   PROGRAMMER  |
|:-----------:|:-------------:|
| 1 : VCC-3V3 |           3V3 |
| 2 : E-RX    |           TXD |
| 3 : E-TX    |           RXD |
| 4: GND      |           GND |
| 5 : GPIO14  | Not connected |  

With pin 1 the pin against the switch on the Sonoff device.  
Please be sure that the Sonoff device is not connected to 120V or 230V...  
Now connect your programmer to your computer using a USB cable AND press the button on the Sonoff device when plugging in to enable write mode.

#### Flash the Sonoff with the Tasmota  
In atom, click on the 'platformio.ini' file (located at the bottom in the tree view), then go to 'PlatformIO -> Upload' to (build and) upload the firmware into the Sonoff device.  
When the code is successfully loaded into the Sonoff device, go to 'PlatformIO -> Serial monitor' and select your serial device (programmer) in the dropdown list. Then you can set the baudrate to '115200'. Click 'start' to start the serial monitor.  
When the messages stop appearing, unplug and replug the VCC pin of the Sonoff device (pin 1 in the previous table). This will restart the device.  
In the logs that appear, you'll now find a log that will look like this:  
> 00:00:08 HTTP: Webserver active on sonoff-1234.local with IP address 192.168.1.50  

You can now surf to your Sonoff device with your favorite webbrowser. Go to 'sonoff-1234.local' or '192.168.1.50' to open the web interface of the Sonoff device.

## Install Sonoff HAP-NodeJS packages
To install the Sonoff packages, you have to do absolutely nothing. If you followed this guide, you already have them installed! I included them in the main HAP-NodeJS [installer](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/install%20files/installHAP.sh).

## Configure Sonoff Basic accessory
Firstly, you'll have to create a copy of the example accessory that I've already installed:  
```bash
cp /home/pi/HAP-NodeJS/accessories/examples/SonoffMQTT_accessory.js /home/pi/HAP-NodeJS/accessories/SonoffMQTT_accessory.js
```  
To configure the accessory, you almost have to do the same things like you had to do with the [light accessory](#test-installation---pis-onboard-led-as-light-accessory).  
Open the file '/home/pi/HAP-NodeJS/accessories/SonoffMQTT_accessory.js'. In [this file](https://github.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/blob/master/accessories/SonoffMQTT_accessory.js#L16) you must edit (at least) these lines:
- **Line 16**: This will be the name of the accessory.  
- **Line 17**: This will be the pincode that you'll need to connect to the accessory.  
- **Line 18**: This must be a unique hexadecimal code (0-9 and A-F), unique for every accessory.  
- **Line 21**: This is the name of the Sonoff device that you've configured on the web interface of the Sonoff device (see next paragraph).  
Save the file and exit.

Secondly, we'll change some settings on the Sonoff's web interface. Open the website of the Sonoff device and then click on 'Configuration -> Configure MQTT'. Here we will change 2 things:
- **Host**: Enter the static IP of your Raspberry Pi.
- **Topic**: Enter a name for the device WITHOUT spaces. (E.g. 'kitchenlights')  


Click save to save this configuration and restart the device.  
If you now open 'Console' on the website of the device, you should be able to see the MQTT commands if the device has been connected successfully to the Raspberry Pi.  
Next go to 'configuration -> Configure other'. Here we will change again 2 things:
- **Friendly name**: A friendly name for the device. (E.g. 'Kitchen Lights')
- **Emulation**: We select 'Belkin WeMo'.
Click save to save this configuration.  

Lastly, we go to our raspberry pi and restart the HAP-NodeJS server with the following command:
```bash
restartHAP
```  

## Send commands directly
This is a quick tip, but you can send commands directly to your Sonoff device from your raspberry pi. For more information on this, check [this wiki](https://github.com/arendst/Sonoff-Tasmota/wiki/Commands).
