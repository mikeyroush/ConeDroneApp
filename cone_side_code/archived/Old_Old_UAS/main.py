import app,light
from sensor import Sensor
import time
def main():

    light.updateLight(False)
    time.sleep(2)
    print("READY")
    lightDisplay = False
    readyToSense = True
    app.startUp()
    sensor = Sensor()
    while True:
        isSensed = sensor.readSensor()
        reset = app.getReset()
        if reset:
            readyToSense = True
            lightDisplay = False
            light.updateLight(lightDisplay)

        if isSensed and readyToSense:
            print("Object detected in range")
            lightDisplay = True
            readyToSense = False
            light.updateLight(lightDisplay)
            app.setStatus(2)


if __name__ == "__main__":
    try:
        main()
    except:
        #print("Reading in ctrl+c, shutting off light")
        #app.setStatus(5)
        light.updateLight(False)
