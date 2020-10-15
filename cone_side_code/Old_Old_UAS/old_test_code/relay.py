import RPi.GPIO as GPIO
import time
import numpy as np
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

TESTLIGHT = 21

GPIO.setup(TESTLIGHT,GPIO.OUT)

#LOW signal means action, high means no action
GPIO.setup(4, GPIO.IN)
# GPIO.setup(5, GPIO.IN)

#LED High=on, low=off
GPIO.output(TESTLIGHT,GPIO.LOW)

while True:
	print "WAITING..."
	#statefar = []
	#stateclose = []
	#for i in range(30):
	#	statefar.append( GPIO.input(4))
	#	stateclose.append(GPIO.input(5))
	#	time.sleep(0.05)
	#sumFar = np.sum(statefar)
	#sumClose = np.sum(stateclose)
	#print "far: " + str(statefar) + " close: "+str(stateclose)
	#print "sumFar: " +str(sumFar) + " sumClose: "+str(sumClose)
	#if sumClose>8 and sumClose<sumFar:
	if not GPIO.input(4):
		print "HIGH SIGNAL RECIEVED"
		print "LED ON"
		GPIO.output(TESTLIGHT,GPIO.HIGH)
		time.sleep(5)
		print "LED OFF"
		GPIO.output(TESTLIGHT,GPIO.LOW)
		time.sleep(2)
