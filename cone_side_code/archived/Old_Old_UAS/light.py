import RPi.GPIO as GPIO
import time
lightPin = 21

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(lightPin, GPIO.OUT)

def updateLight(state):
	if(state):
		#Due to the new transistor output, LOW = LIGHT
		GPIO.output(lightPin,GPIO.LOW)
	else:
		GPIO.output(lightPin,GPIO.HIGH)
