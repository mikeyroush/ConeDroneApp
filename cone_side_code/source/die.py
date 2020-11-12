import signal
import sys
import RPi.GPIO as GPIO 
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import sensor
import schedule
import indicator
GPIO.setwarnings(False)

indicator.clearLEDS()
indicator.lowerFlag()