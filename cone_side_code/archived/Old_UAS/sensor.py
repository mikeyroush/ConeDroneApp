import RPi.GPIO as GPIO
import time

class Sensor:
    def __init__(self,headless):
        #Headless mode
        #True: No console output
        #False: Console output
        self.headless_mode=headless

        #Setup the variables for detection
        self.last_close_read = 0
        self.last_far_read = 0
        self.threshold = 0.25

        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        #Input Setup:
        #Pin 5 = far sensor
        #Pin 4 = close sensor
        self.FAR_PIN = 5
        self.CLOSE_PIN = 4
        GPIO.setup(self.CLOSE_PIN, GPIO.IN)
        GPIO.setup(self.FAR_PIN, GPIO.IN)

        GPIO.add_event_detect(self.CLOSE_PIN,GPIO.BOTH)
        GPIO.add_event_callback(self.CLOSE_PIN,self.close_sensor_read)
        GPIO.add_event_detect(self.FAR_PIN,GPIO.BOTH)
        GPIO.add_event_callback(self.FAR_PIN,self.far_sensor_read)

        self.my_print("Sensor setup!")

    def my_print(self,text):
        if not self.headless_mode:
            print(text)

    def close_sensor_read(self,pin):
        self.last_close_read=time.time()

    def far_sensor_read(self,pin):
        self.last_far_read = time.time()

    def readSensor(self):
        #read signal
        close_sensor = GPIO.input(self.CLOSE_PIN)
        far_sensor = GPIO.input(self.FAR_PIN)

        #Calculate the time since the last far and last close read. self variables and saved from the interrupt functions
        far_elapsed = time.time()-self.last_far_read
        close_elapsed = time.time() - self.last_close_read

        #Calculate if the close sensor has occured within the threshold time of the far sensor
        #Additionally we check if the close time has happened recently and not an old reading.
        if close_elapsed < far_elapsed+self.threshold and close_elapsed < self.threshold*3:
            self.my_print("Light off, Deadzone detected"+"\ntime since far:" + str(far_elapsed)+ " time since close:" + str(close_elapsed))
            return False
        #Similar to the previous if- here we calculate if the far sensor has occured after we check for the deadzone
        #We want to see here that it's occured after the threshold and has happened recently. If this is the case, we return true
        elif far_elapsed>self.threshold and far_elapsed < self.threshold*2:
            self.my_print("Light on, Far detected"+"\ntime since far:" + str(far_elapsed)+ " time since close:" + str(close_elapsed))
            return True
        else:
            self.my_print("Hit else. Returning false."+"\ntime since far:" + str(far_elapsed)+ " time since close:" + str(close_elapsed))
            return False
