import RPi.GPIO as GPIO
import time
#import numpy as np

class Sensor:
    def __init__(self):
        #Setup the variables for detection
        self.last_close_read = 0
        self.last_far_read = 0
        self.threshold = 0.25
        self.cur = GPIO.LOW
        self.disp_time = 0
        self.disp_interval = 0.1
        self.deadzone = False
        self.far_clear = False

        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        #Input Setup:
        #Pin 4 = far sensor
        #Pin 5 = close sensor
        self.FAR_PIN = 5
        self.CLOSE_PIN = 4
        GPIO.setup(self.CLOSE_PIN, GPIO.IN)
        GPIO.setup(self.FAR_PIN, GPIO.IN)

        GPIO.add_event_detect(self.CLOSE_PIN,GPIO.BOTH)
        GPIO.add_event_callback(self.CLOSE_PIN,self.close_sensor_read)
        GPIO.add_event_detect(self.FAR_PIN,GPIO.BOTH)
        GPIO.add_event_callback(self.FAR_PIN,self.far_sensor_read)

        print("SENSOR SETUP!")

    def close_sensor_read(self,pin):
        self.last_close_read=time.time()

    def far_sensor_read(self,pin):
        #self.prev_far_read = self.last_far_read
        self.last_far_read = time.time()

    def readSensor(self):

        close_sensor = GPIO.input(self.CLOSE_PIN)
        far_sensor = GPIO.input(self.FAR_PIN)
        #waiting for signal
        #Set this to low for now while testing the functionality. IN the future, this low will come from the actual code.
        #GPIO.output(testlight, cur)
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

        far_elapsed = time.time()-self.last_far_read
        close_elapsed = time.time() - self.last_close_read
        if close_elapsed < far_elapsed+self.threshold and close_elapsed < self.threshold*3:
            self.deadzone=True
            #if(cur==GPIO.HIGH):
            #print "Deadzone has been entered. Please adjust object to far sensor"
            #GPIO.output(testlight, GPIO.LOW)
            #cur = GPIO.LOW
            #time.sleep(2)
            print("\tLight off,Deadzone detected")
            self.deadzone=False
            return False
        elif far_elapsed>self.threshold and far_elapsed < self.threshold*2:
            self.far_clear=True
            #if(not cur==GPIO.HIGH):
            #print "Far sensor has been cleared successfully."
            #GPIO.output(testlight, GPIO.HIGH)
            self.cur = GPIO.HIGH
            #time.sleep(2)
            print("\tLight on, Far detected")
            self.far_clear=False
            return True
        else:
            #print("hit else, returning false")
            return False

        # if(time.time()-self.disp_time > self.disp_interval):
        #     print("\ntime since far:" + str(far_elapsed))
        #     print("time since close:" + str(close_elapsed))
        #     if(self.far_clear):
        #         print("\tLight on, Far detected")
        #         self.far_clear=False
        #         return True
        #     elif(self.deadzone):
        #         print("\tLight off,Deadzone detected")
        #         self.deadzone=False
        #         return False
        #     self.disp_time=time.time()
