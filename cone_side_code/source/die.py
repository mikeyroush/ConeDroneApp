import signal
import sys
#import RPi.GPIO as GPIO disabled for the moment because I'm on my windows machine
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import sensor
import schedule
import indicator

indicator.indicator_flag(False)
indicator.indicator_led(False, False)