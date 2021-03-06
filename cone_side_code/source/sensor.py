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
MAX_DISTANCE = 800
MAX_AMPLITUDE = 1500 #false positives often have weirdly high amplitudes for supposedly being 4+ meters away.
last_triggered = False
previous_distane = 0


global dist
################################################################################################################
#configuring

#this opens an smbus, and closes it at the end of this block.
with SMBus(1) as bus:
    #write_byte_data(address, register, data)
    bus.write_byte_data(0x10, 0x23, 0x00) #set sensor to continuous mode
    bus.write_byte_data(0x10, 0x25, 0x01) #enable lidar sensor. The documentation straight-up lies, it says setting this to *0x00* enables the sensor.
    bus.write_byte_data(0x10, 0x26, 0x02) #set read period to 20ms
    bus.write_byte_data(0x10, 0x27, 0x00) #set read period to 20ms
    bus.write_byte_data(0x10, 0x28, 0x00) #disable low power mode

    bus.write_byte_data(0x10, 0x2A, 0x64) #set minimum amplitude to 100

    #minimum amplitude, and minimum/maximum distances work just fine with the default values (100, and .2m and 8m respectively).
    #reads below the amplitude get set to the dummy value, which is 0. IE: uncertain things get sent to the Zero Distance box, which we already don't care about.

GPIO.setmode(GPIO.BCM) #use GPIO numbers
GPIO.setup(PIN6_PIN, GPIO.IN) #gotta read from this one
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
'''
def interpretDistance(distance):
    return (distance > MIN_DISTANCE and distance < MAX_DISTANCE)
    if (last_triggered and distance > MIN_DISTANCE and distance < MAX_DISTANCE):
        return True
    last_triggered = (distance > MIN_DISTANCE and distance < MAX_DISTANCE)
    return False
'''

#noise filtering try 1
def interpretDistance(distance):
    global last_triggered
    if (last_triggered and distance > MIN_DISTANCE and distance < MAX_DISTANCE):
        last_triggered = False
        return True
    last_triggered = (distance > MIN_DISTANCE and distance < MAX_DISTANCE)
    return False
#this one seemed to work pretty good, actually. Neat!
'''
#noise filtering try 2
def interpetDistance(distance):
    use_dist = (previous_distance + distance) / 2
    return (use_dist > MIN_DISTANCE and use_dist < MAX_DISTANCE)
'''
