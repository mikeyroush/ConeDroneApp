import sys
import app,light
from sensor import Sensor
import time
def main(headless_mode):
    lightDisplay = False
    readyToSense = True
    #Turn off light to signal app is ready
    light.updateLight(lightDisplay)
    time.sleep(2)
    app.startUp()
    sensor = Sensor(headless_mode)
    while True:
        #Read if an object is there on the sensor
        isSensed = sensor.readSensor()

        #Read if the reset signal has been hit for the cone
        reset = app.getReset()
        if reset:
            readyToSense = True
            lightDisplay = False
            light.updateLight(lightDisplay)

        #Check for a reset signal or initial signal before telling the app an object is read
        #This prevents unneeded delay when telling the app something is active multiple times
        if isSensed and readyToSense:
            lightDisplay = True
            readyToSense = False
            light.updateLight(lightDisplay)
            app.setStatus(2)


if __name__ == "__main__":
    try:
        headless = False
        for i in range(1,len(sys.argv)):
	    if sys.argv[i].lower() == "headless":
               headless = True
        print("headless: "+str(headless))
	main(headless)
    except:
        print("shutting off light")
        app.setStatus(5)
        light.updateLight(False)
