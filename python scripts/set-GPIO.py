from RPi import GPIO
import time
import sys

pinNr = int(sys.argv[1])

GPIO.setwarnings(False)

GPIO.setmode(GPIO.BOARD)
GPIO.setup(pinNr, GPIO.OUT)
if int(sys.argv[2]) == 1:
    GPIO.output(pinNr, GPIO.HIGH)
else:
    GPIO.output(pinNr, GPIO.LOW)
