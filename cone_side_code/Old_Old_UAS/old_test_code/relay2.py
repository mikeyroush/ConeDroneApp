import RPi.GPIO as GPIO
import time
import numpy as np
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

#Beacon light assigned to pin 21 and it used as output
testlight = 21
GPIO.setup(testlight, GPIO.OUT)

#Input Setup:
#Pin 4 = far sensor
#Pin 5 = close sensor
GPIO.setup(5, GPIO.IN)
GPIO.setup(4, GPIO.IN)

#notes:
#low signal = action
#high signal = no action
# -----
#LED high = on
#LED low = off

#start off with beacon-light off
GPIO.output(testlight, GPIO.LOW)

last_close_read = 0
last_far_read = 0
threshold = 0.7
cur = GPIO.LOW
disp_time = 0
disp_interval = 0.5
deadzone = False
far_clear = False

#So I know when to test the program
GPIO.output(testlight, GPIO.HIGH)
time.sleep(5)
GPIO.output(testlight, GPIO.LOW)

def close_sensor_read(pin):
    global last_close_read
    last_close_read=time.time()

def far_sensor_read(pin):
    global  last_far_read
    last_far_read = time.time()

GPIO.add_event_detect(5,GPIO.BOTH)
GPIO.add_event_callback(5,close_sensor_read)
GPIO.add_event_detect(4,GPIO.BOTH)
GPIO.add_event_callback(4,far_sensor_read)

try:
    while True:
        close_sensor = GPIO.input(5)
        far_sensor = GPIO.input(4)
        #waiting for signal
        #Set this to low for now while testing the functionality. IN the future, this low will come from the actual code.
        GPIO.output(testlight, cur)
        #print "Listening... "
        #conditionals:
        #if close_sens goes off, we need to delay the input for far sens because object is too close
        #if far_sens goes off, we either:
        #turn off deadzone because object has cleared correct space
        #keep deadzone on for constant listening incase object comes to close
        #if not close_sensor:
	    #if(time.time()-last_close_read >0.2):
	        #print "close read"
	    #last_close_read = time.time()
        #if not far_sensor:
	    #if(time.time()-last_far_read >0.2):
	        #print "far read"
	    #last_far_read = time.time()

        far_elapsed = time.time()-last_far_read
        close_elapsed = time.time() - last_close_read
        if close_elapsed < far_elapsed+threshold and close_elapsed < threshold*3:
            deadzone=True
	    #if(cur==GPIO.HIGH):
	        #print "Deadzone has been entered. Please adjust object to far sensor"
            #GPIO.output(testlight, GPIO.LOW)
	    #cur = GPIO.LOW
            #time.sleep(2)
        elif far_elapsed>threshold and far_elapsed < 2*threshold:
	    far_clear=True
            #if(not cur==GPIO.HIGH):
	        #print "Far sensor has been cleared successfully."
            #GPIO.output(testlight, GPIO.HIGH)
	    cur = GPIO.HIGH
	    #time.sleep(2)

        if(time.time()-disp_time > disp_interval):
	    print("\ntime since far:" + str(far_elapsed))
	    print("time since close:" + str(close_elapsed))
	    if(far_clear):
	        print("\tLight on, Far detected")
	        far_clear=False
	    elif(deadzone):
	        print("\tLight off,Deadzone detected")
	        deadzone=False
	    disp_time=time.time()
except KeyboardInterrupt:
    GPIO.output(testlight,GPIO.LOW)
