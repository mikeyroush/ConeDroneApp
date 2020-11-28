#quick 'n dirty script for testing the amplitude of readings gotten through the sensor.
import signal
import sys
#import RPi.GPIO as GPIO disabled for the moment because I'm on my windows machine
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import sensor
import indicator

sensor.MIN_DISTANCE = 400
while (True):
    with SMBus(1) as bus:
        dist = bus.read_byte_data(0x10, 0x00)#
        dist = dist + (bus.read_byte_data(0x10, 0x01) << 8)
        amp = bus.read_byte_data(0x10, 0x02)
        amp = amp + (bus.read_byte_data(0x10, 0x03) << 8)
    
    #only print out ones that are actually interesting
    if dist > sensor.MIN_DISTANCE and dist < sensor.MAX_DISTANCE:
        print("distance: ", dist)
        print("amplitude: ", amp)
        print()
    time.sleep(.005)