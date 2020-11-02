import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(21,GPIO.OUT)
GPIO.output(21,GPIO.LOW)

while True:
	print "GPIO HIGH"
	GPIO.output(21,GPIO.HIGH)
	time.sleep(3)
	print "GPIO LOW"
	GPIO.output(21,GPIO.LOW)
	time.sleep(3)
