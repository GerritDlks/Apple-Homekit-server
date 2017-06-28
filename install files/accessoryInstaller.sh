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

# Display the welcome dialog
  whiptail --title "HAP-NodeJS accessory installer" --msgbox "\n\nThis installer will install a HAP-NodeJS accessory with you having to worry about it." ${r} ${c}

# Ask a name for the accessory
NAME=$(whiptail --inputbox "\n\nWhat's the name of your new accessory?" ${r} ${c} "kitchen light" --title "Accessory name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
    exit 1
fi

#Check length
NAME_LEN=$(echo ${#NAME})
if [ $NAME_LEN -le 0 ]; then
    echo "the name can't be empty... Exiting..."
    exit 1
fi

whiptail --title "Accessory name" --msgbox "\n\nThe selected name is:\n $NAME" ${r} ${c}

# Ask for a pincode
PIN=$(whiptail --inputbox "\n\nWhat will the PIN-code be for this accessorry?\nThe PIN-code is a 8 digits code. Dashes will be added automatically." ${r} ${c} "12345678" --title "Accessory PIN-code" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
    exit 1
fi

#Check length
PIN_LEN=$(echo ${#PIN})
if [ $PIN_LEN -ne 8 ]; then
    echo "the number of digits for the PIN-code is not equal too 8... Exiting..."
    exit 1
fi

#Add dashes to PIN
PIN=${PIN:0:3}-${PIN:3:2}-${PIN:5:3}

whiptail --title "Accessory PIN-code" --msgbox "\n\nThe selected PIN-code is:\n $PIN" ${r} ${c}


#Create random username (mac-like address)
USERNAME=$(printf '%02X:%02X:%02X:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])

whiptail --title "Accessory username (random MAC-like address)" --msgbox "\n\nThe generated username is:\n $USERNAME\n\nPS: You don't have to worry about this, it's needed internally for Apple Home to be able to work." ${r} ${c}



# Ask a manufacturer name for the accessory
MANU_NAME=$(whiptail --inputbox "(optional)\n\nWhat's the manufacturer's name of your new accessory?\n\nE.g. Apple" ${r} ${c} "" --title "Accessory name of manufacturer (optional)" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
    exit 1
fi

#Check length
MANU_NAME_LEN=$(echo ${#MANU_NAME})
if [ $MANU_NAME_LEN -le 0 ]; then
    whiptail --title "Accessory name of manufacturer (otional)" --msgbox "\n\nYou did not set a manufacturer's name. No manufacturer's name will be shown." ${r} ${c}
else
    whiptail --title "Accessory name of manufacturer (otional)" --msgbox "\n\nThe selected manufaturer's name is:\n $NAME" ${r} ${c}
fi



# Ask a version for the accessory
VERSION=$(whiptail --inputbox "(optional)\n\nWhat's the version number of your new accessory?\n\nE.g. v1.0" ${r} ${c} "" --title "Accessory version (optional)" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
    exit 1
fi

#Check length
VERSION_LEN=$(echo ${#VERSION})
if [ $VERSION_LEN -le 0 ]; then
    whiptail --title "Accessory version (otional)" --msgbox "\n\nYou did not set a version number. No version number will be shown." ${r} ${c}
else
    whiptail --title "Accessory version (optional)" --msgbox "\n\nThe selected version number is:\n $VERSION" ${r} ${c}
fi



# Ask a serial number for the accessory
SER=$(whiptail --inputbox "(optional)\n\nWhat's the serial number of your new accessory?\n\nE.g. AE3294RF32" ${r} ${c} "" --title "Accessory serial number (optional)" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
    exit 1
fi

#Check length
SER_LEN=$(echo ${#SER})
if [ $SER_LEN -le 0 ]; then
    whiptail --title "Accessory serial number (otional)" --msgbox "\n\nYou did not set a serial number. No serial number will be shown." ${r} ${c}
else
    whiptail --title "Accessory serial number (optional)" --msgbox "\n\nThe selected name is:\n $SER" ${r} ${c}
fi
