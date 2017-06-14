import sys
import os

os.system("echo none | sudo tee /sys/class/leds/led0/trigger")
os.system("echo " + str(sys.argv[1]) + " | sudo tee /sys/class/leds/led0/brightness")
