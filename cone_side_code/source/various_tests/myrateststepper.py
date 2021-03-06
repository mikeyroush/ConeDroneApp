#Quick 'n dirty testing for a stepper motor. 

import signal
import sys
#import RPi.GPIO as GPIO disabled for the moment because I'm on my windows machine
import schedule #using the schedule library, by Daniel Bader (Task scheduling)
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import RPi.GPIO as GPIO
import schedule
GPIO.setwarnings(False)

GPIO.setmode(GPIO.BCM)
p = GPIO.PWM(12, 50)
p.start(7) #2 to 12
time.sleep(1)
p.ChangeDutyCycle(12) #2 = 0 degrees, 12 = 180 degrees
time.sleep(1)
p.stop()