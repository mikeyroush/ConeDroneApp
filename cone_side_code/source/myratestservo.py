import signal
import sys
#import RPi.GPIO as GPIO disabled for the moment because I'm on my windows machine
import schedule #using the schedule library, by Daniel Bader (Task scheduling)
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import RPi.GPIO as GPIO
import schedule

GPIO.setmode(GPIO.BOARD)

p = GPIO.PWM(0, 1000)
p.start(5)
time.sleep(4)