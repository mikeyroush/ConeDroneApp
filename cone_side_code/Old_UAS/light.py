import RPi.GPIO as GPIO
import time
lightPin = 21

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(lightPin, GPIO.OUT)

#Transistor logic: GPIO HIGH = Light off, GPIO LOW = Light On
def updateLight(state):
	if(state):
		#True input: Light
		GPIO.output(lightPin,GPIO.LOW)
	else:
		#False input: No light
		GPIO.output(lightPin,GPIO.HIGH)
