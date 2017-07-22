#!/usr/bin/env bash

# Find the rows and columns will default to 80x24 is it can not be detected
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo "${screen_size}" | awk '{print $1}')
columns=$(echo "${screen_size}" | awk '{print $2}')

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

# ------------------------------------------------------------------------------

# clean up previous stuff that was not cleaned up nicely
sudo rm -f ~/HAP-NodeJS/accessories/tempFile.js > /dev/null

# ------------------------------------------------------------------------------

function Welcome() {
  whiptail --title "HAP-NodeJS accessory installer" --msgbox "\n\nThis installer will install a HAP-NodeJS accessory with you having to worry about it." ${r} ${c}
}

function AskKindOfDevice() {
  #Ask if it is a GPIO pin or Sonoff device that they want to toggle
  numberOfOptions=2
  DEVICE_KIND=$(whiptail --title "What accessory do you want to configure?" --menu "Choose your option" ${r} ${c} ${numberOfOptions} \
  "Sonoff" "     Sonoff switch" \
  "GPIO" "     Raspberry Pi GPIO pin" 3>&1 1>&2 2>&3)
  if [ $DEVICE_KIND = "" ]; then exit 1; fi
}

function AskName() {
  # Ask a name for the accessory
  NAME=$(whiptail --inputbox "\n\nWhat's the name of your new accessory?" ${r} ${c} "kitchen light" --title "Accessory name" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      echo "You must provide a name... Exiting..."
      exit 1
  fi

  #Check length
  NAME_LEN=$(echo ${#NAME})
  if [ $NAME_LEN -le 0 ]; then
      echo "The name can't be empty... Exiting..."
      exit 1
  fi

  # whiptail --title "Accessory name" --msgbox "\n\nThe selected name is:\n $NAME" ${r} ${c}
}

function AskPIN() {
  # Ask for a pincode
  PIN=$(whiptail --inputbox "\n\nWhat will the PIN-code be for this accessorry?\nThe PIN-code is a 8 digits code. Dashes will be added automatically." ${r} ${c} "12345678" --title "Accessory PIN-code" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      echo "You must provide a name... Exiting..."
      exit 1
  fi

  #Check length
  PIN_LEN=$(echo ${#PIN})
  if [ $PIN_LEN -ne 8 ]; then
      echo "The number of digits for the PIN-code is not equal too 8... Exiting..."
      exit 1
  fi

  #Add dashes to PIN
  PIN=${PIN:0:3}-${PIN:3:2}-${PIN:5:3}

  # whiptail --title "Accessory PIN-code" --msgbox "\n\nThe selected PIN-code is:\n $PIN" ${r} ${c}
}

function CreateUsername() {
  #Create random username (mac-like address)
  USERNAME=$(printf '%02X:%02X:%02X:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])

  # whiptail --title "Accessory username (random MAC-like address)" --msgbox "\n\nThe generated username is:\n $USERNAME\n\nPS: You don't have to worry about this, it's needed internally for Apple Home to be able to work." ${r} ${c}
}

function AskManufacturerName() {
  # Ask a manufacturer name for the accessory
  MANU_NAME=$(whiptail --inputbox "(optional)\n\nWhat's the manufacturer's name of your new accessory?\n\nE.g. Apple" ${r} ${c} "" --title "Accessory name of manufacturer (optional)" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      MANU_NAME=""
      return 0
  fi

  #Check length
  MANU_NAME_LEN=$(echo ${#MANU_NAME})
  if [ $MANU_NAME_LEN -le 0 ]; then
      whiptail --title "Accessory name of manufacturer (otional)" --msgbox "\n\nYou did not set a manufacturer's name. No manufacturer's name will be shown." ${r} ${c}
      MANU_NAME=""
  # else
  #     whiptail --title "Accessory name of manufacturer (otional)" --msgbox "\n\nThe selected manufaturer's name is:\n $NAME" ${r} ${c}
  fi
}

function AskVersion() {
  # Ask a version for the accessory
  VERSION=$(whiptail --inputbox "(optional)\n\nWhat's the version number of your new accessory?\n\nE.g. v1.0" ${r} ${c} "" --title "Accessory version (optional)" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      VERSION=""
      return 0
  fi

  #Check length
  VERSION_LEN=$(echo ${#VERSION})
  if [ $VERSION_LEN -le 0 ]; then
      whiptail --title "Accessory version (otional)" --msgbox "\n\nYou did not set a version number. No version number will be shown." ${r} ${c}
      VERSION=""
  # else
  #     whiptail --title "Accessory version (optional)" --msgbox "\n\nThe selected version number is:\n $VERSION" ${r} ${c}
  fi
}

function AskSerialNumber() {
  # Ask a serial number for the accessory
  SER=$(whiptail --inputbox "(optional)\n\nWhat's the serial number of your new accessory?\n\nE.g. AE3294RF32" ${r} ${c} "" --title "Accessory serial number (optional)" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      SER=""
      return 0
  fi

  #Check length
  SER_LEN=$(echo ${#SER})
  if [ $SER_LEN -le 0 ]; then
      whiptail --title "Accessory serial number (otional)" --msgbox "\n\nYou did not set a serial number. No serial number will be shown." ${r} ${c}
      SER=""
  # else
  #     whiptail --title "Accessory serial number (optional)" --msgbox "\n\nThe selected name is:\n $SER" ${r} ${c}
  fi
}

function AskGPIOnr() {
  # Ask a pin number
  GPIONR=$(whiptail --inputbox "\n\nWhat's the number of the pi's GPIO that you want to control?" ${r} ${c} "16" --title "Pi's GPIO number" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
      echo "You must provide a PIN number... Exiting..."
      exit 1
  fi

  # Check if number
  regex='^[0-9]+$'
  if ! [[ $GPIONR =~ $regex ]] ; then
     echo "The GPIO number must be a number... Exiting..."
     exit 1
  fi
}

function ConfigureSonoffViawebinterface() {
  whiptail --title "Configure the Sonoff device" --msgbox "To be able to control the Sonoff device, you must configure it through the web interface after flashing the custom firmware on the Sonoff device.\
\n\nConfiguration -> Configure MQTT -> Topic:\
\n    This is the topic name for the Sonoff device (e.g.: 'kitchenlights').\n    This name can not contain spaces.\n    Also, remember this name for the next screen.\
\n\nConfiguration -> Configure MQTT -> Host:\
\n    This is the static IP address of your Raspberry Pi (e.g.: '192.168.1.200').\
\n\nconfiguration -> Configure other' -> Friendly name:\
\n    This is a Friendly name for the Sonoff device (e.g.: 'Kitchen lights').\
\n\nconfiguration -> Configure other' -> Emulation:\
\n    Choose for 'Belkin Wemo'.\
" ${r} ${c}
}

function AskMQTTName() {
  # Ask a name for the accessory
  MQTT_NAME=$(whiptail --inputbox "\n\nWhat's the topic name of your new MQTT accessory?\n\nThis is the 'topic' name that has been set on the Sonoff device's web interface.\n\nIt cannot contain spaces!" ${r} ${c} "kitchenlight" --title "MQTT topic name" 3>&1 1>&2 2>&3)
  if [ $? != 0 ]; then
      echo "You must provide a topic name... Exiting..."
      exit 1
  fi

  # remove spaces
  MQTT_NAME="${MQTT_NAME// /}"

  #Check length
  MQTT_NAME_LEN=$(echo ${#MQTT_NAME})
  if [ $MQTT_NAME_LEN -le 0 ]; then
      echo "the topic can't be empty... Exiting..."
      exit 1
  fi

  # whiptail --title "Accessory name" --msgbox "\n\nThe selected topic name is:\n $NAME" ${r} ${c}
}

# ------------------------------------------------------------------------------

function ConfigureGPIOAccessory() {
  AskName
  AskPIN
  CreateUsername
  AskManufacturerName
  AskVersion
  AskSerialNumber
  AskGPIOnr

  { echo 0; sleep 1; } | whiptail --title "Please wait" --gauge "\n\nPlease wait while we are installing everything..." 8 ${c} 0

  {
    echo 20;
    sudo wget -O ~/HAP-NodeJS/accessories/tempFile.js https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/accessories/Light_GPIO_accessory.js &> /dev/null
    echo 39;

    lineNr=$(grep -n "  name: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  name: \"$NAME\",/" tempFile.js

    lineNr=$(grep -n "  pincode: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  pincode: \"$PIN\",/" tempFile.js

    lineNr=$(grep -n "  username: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  username: \"$USERNAME\",/" tempFile.js

    lineNr=$(grep -n "  manufacturer: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  manufacturer: \"$MANU_NAME\",/" tempFile.js

    lineNr=$(grep -n "  model: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  model: \"$VERSION\",/" tempFile.js

    lineNr=$(grep -n "  serialNumber: " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/  serialNumber: \"$SER\",/" tempFile.js

    lineNr=$(grep -n "var pinNr = " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/var pinNr = $GPIONR;/" tempFile.js
  } | whiptail --title "Please wait" --gauge "\n\nPlease wait while we are installing everything..." 8 ${c} 0
}

function ConfigureSonoffAccessory() {
  AskName
  AskPIN
  CreateUsername
  ConfigureSonoffViawebinterface
  AskMQTTName

  { echo 0; sleep 1; } | whiptail --title "Please wait" --gauge "\n\nPlease wait while we are installing everything..." 8 ${c} 0

  {
    echo 20;
    sudo wget -O ~/HAP-NodeJS/accessories/tempFile.js https://raw.githubusercontent.com/Kevin-De-Koninck/Apple-Homekit-and-PiHole-server/master/accessories/SonoffMQTT_accessory.js &> /dev/null
    echo 39;

    lineNr=$(grep -n "var name = " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/var name = \"$NAME\";/" tempFile.js

    lineNr=$(grep -n "var pincode = " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/var pincode = \"$PIN\";/" tempFile.js

    lineNr=$(grep -n "var sonoffUsername = " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/var sonoffUsername = \"$USERNAME\";/" tempFile.js

    lineNr=$(grep -n "var MQTT_NAME = " tempFile.js | cut -d : -f 1)
    sudo sed -i "$lineNr s/.*/var MQTT_NAME = \"$MQTT_NAME\";/" tempFile.js
    } | whiptail --title "Please wait" --gauge "\n\nPlease wait while we are installing everything..." 8 ${c} 0
}

# ------------------------------------------------------------------------------

Welcome
AskKindOfDevice

case $DEVICE_KIND in
  "Sonoff" )
    ConfigureSonoffAccessory
    ;;
  "GPIO" )
    ConfigureGPIOAccessory
    ;;
esac

{
  echo 55; sleep 0.3;
  # remove spaces from name to use as name for file
  NAME_SPACELESS="${NAME// /}"
  USERNAME_DIGITS_ONLY="${USERNAME//:/}"

  # Move accessory
  sudo mv ~/HAP-NodeJS/accessories/tempFile.js ~/HAP-NodeJS/accessories/${NAME_SPACELESS}_${USERNAME_DIGITS_ONLY}_accessory.js

  echo 82;
  # Restart the HAP server
  /home/pi/HAP-NodeJS/startHAP.sh &> /dev/null

  echo 99; sleep 0.5; echo 100; sleep 1.5
} | whiptail --title "Please wait" --gauge "\n\nPlease wait while we are installing everything..." 8 ${c} 0
# Show summary
whiptail --title "SUMMARY" --msgbox "The following settings were set using this installer. Use these settings to find and add your new accessory to the Apple Home app.\
\n\nName:\
\n    $NAME\
\n\nPIN:\
\n    $PIN\
\n\n\n\nIf you'd want to remove the accessory from your HAP-NodeJS server, execute the following command:\
\nrm -f ~/HAP-NodeJS/accessories/${NAME_SPACELESS}_${USERNAME_DIGITS}_ONLY_accessory.js && restartHAP" ${r} ${c}
