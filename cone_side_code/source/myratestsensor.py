import signal
import sys
#import RPi.GPIO as GPIO disabled for the moment because I'm on my windows machine
from smbus2 import SMBus #using smbus2 by Karl-Petter Lindegaard (I2C messaging)
import time
import sensor
import schedule
import indicator

'''
with SMBus(1) as bus:
    #I hope the sensors still have their default address!
    bus.write_byte_data(0x10, 0x23, 0x01) #set sensor to continuous mode
    bus.write_byte_data(0x10, 0x25, 0x01) #enable lidar sensor. The documentation straight-up lies, it says setting this to *0x00* enables the sensor.
    bus.write_byte_data(0x10, 0x26, 0x04) #set read period to 20ms (I think!)
    bus.write_byte_data(0x10, 0x27, 0x00) #set read period to 20ms
    bus.write_byte_data(0x10, 0x28, 0x00) #disable low power mode

def sensorCheckTest():
    if not GPIO.input(37):
        GPIO.wait_for_edge(37, GPIO.RISING, 1000)
    
    #TFLuna stores data in 2 registers, one byte each. First is the low half of the result, second is the high half. 
    with SMBus(1) as bus: 
        dist = bus.read_byte_data(10, 0)
        dist = dist + bus.read_byte_data(10, 1) << 8 #I THINK that should give me the right answer...? I'm unsure...

honk = True
while(honk):
    with SMBus(1) as bus:
        bus.write_byte_data(10, 24, '0x01')
        time.sleep(.005)
        data = bus.read_byte_data(10, 0)
        data = data + bus.read_byte_data(10, 1) << 8 #I THINK that should give me the right answer...? I'm unsure...
    
    print data 
    honk = False
    time.sleep(.5)
'''
    
'''
schedule.every(.5).seconds().do('checkSensor')

while(True):
    schedule.run_pending():
    time.sleep(.1)
'''

blar = [False, 0]
sensor.MIN_DISTANCE = 400
schedule.every(.004).seconds.do(sensor.checkSensor, distance_arr = blar)
while(True):
    schedule.run_pending()
    if (blar[0]):
        print("distance: ", blar[1])
        with SMBus(1) as bus:
            amp = bus.read_byte_data(0x10, 0x02)
            amp = amp + (bus.read_byte_data(0x10, 0x03) << 8)
            print("amplitude: ", amp)
            print()
            time.sleep(.5)
        


