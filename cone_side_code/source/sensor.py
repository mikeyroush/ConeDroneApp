import signal
import sys
import schedule #using the schedule library, by Daniel Bader (Task scheduling)
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import RPi.GPIO as GPIO

SDA_PIN = 3 #I don't think these are strictly necessary but I'm leaving them anyway
SCL_PIN = 5
PIN6_PIN = 16 #pin 6 on the sensor, which is used to check when data is ready. AKA: when a reading is taken!
MIN_DISTANCE = 400
MAX_DISTANCE = 1000

global dist
################################################################################################################
#configuring

#this opens an smbus, and closes it at the end of this block.
with SMBus(1) as bus:
    #write_byte_data(address, register, data)
    bus.write_byte_data(0x10, 0x23, 0x00) #set sensor to continuous mode
    bus.write_byte_data(0x10, 0x25, 0x01) #enable lidar sensor. The documentation straight-up lies, it says setting this to *0x00* enables the sensor.
    bus.write_byte_data(0x10, 0x26, 0x04) #set read period to 20ms (I think!)
    bus.write_byte_data(0x10, 0x27, 0x00) #set read period to 20ms
    bus.write_byte_data(0x10, 0x28, 0x00) #disable low power mode
    #minimum amplitude, and minimum/maximum distances work just fine with the default values (100, and .2m and 8m respectively).
    #reads below the amplitude get set to the dummy value, which is 0. IE: uncertain things get sent to the Zero Distance box, which we already don't care about.

GPIO.setmode(GPIO.BCM) #use pin numbers instead of GPIO numbers. This'll probably be changed as this section of code is integrated with the rest.
GPIO.setup(PIN6_PIN, GPIO.IN) #gotta read from
################################################################################################################

#The TF-Luna stores data as two bytes, in two registers. Add high * 256 + low, and you get the actual value.
#distance_arr allows this function to modify something without needing to return anything (a particular need schedule demands)
def checkSensor(distance_arr):
    #If the sensor is still updating its registers, wait a sec
    dist = distance_arr[0]
    if not GPIO.input(PIN6_PIN):
        time.sleep(.001)
    
    with SMBus(1) as bus:
        dist = bus.read_byte_data(0x10, 0x00)#
        dist = dist + (bus.read_byte_data(0x10, 0x01) << 8)

    #package information to be sent out (gotta do it weird due to how schedule works)
    distance_arr[0] = interpretDistance(dist)
    distance_arr[1] = dist

def interpretDistance(distance):
    return (distance > MIN_DISTANCE and distance < MAX_DISTANCE)
