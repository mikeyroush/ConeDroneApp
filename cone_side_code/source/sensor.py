#Going to be using the wiringPi library, as it has a very nice I2C portion. 
import signal
import sys
# import RPi.GPIO as GPIO
# import schedule #using the schedule library, by Daniel Bader
# from smbus2 import SMBus, ic_msg #using smbus2 by, Karl-Petter Lindegaard

SDA_PIN = 1
SCL_PIN = 2
PIN_6 = 3 #pin 6 on the sensor, which is used to check when data is ready. AKA: when a reading is taken!


################################################################################################################
#configuring the I2C connection, and the sensor. 
#More detail when you get into the function.
def configureLIDAR():
    pass
    #CONFIGURE THE I2C CONNECTION HERE HONKHONKHONK


################################################################################################################

#The main function will need to schedule checkSensor in its main loop, along with periodically checking on it. 
#Faster than every 20ms would be awesome, but honestly I'm not terribly picky.
def checkSensor(): 
    pass
    #check pin 6 on the lidar.
        #if high, go ahead and read. The documentation is kind of unclear, but I think that should ensure no collisions. 
        #if low, wait until high edge then read. 
    
    #pass the result from that read to interpretDistance
    #when this is scheduled, check it every so often with run_pending. Because 
    
def interpretDistance(distance):
    #This is written into its own function mostly so unit testing can be done on it...
    if (distance > 400): #sensor distance is in cm
        # print("flyover detected, activating indication")
        return True
        #call the trigger function
    
    