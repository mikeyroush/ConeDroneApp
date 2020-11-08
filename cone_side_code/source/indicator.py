import board
import time
import neopixel
import sys
import signal
import RPi.GPIO as GPIO


numPixels = 10
pixels = neopixel.NeoPixel(board.D21, numPixels) #Connected to GPIO 21
SERVO_PWM = 12 #I don't know what these should be 

#set up for pin 12 PWM. 
GPIO.setmode(GPIO.BOARD)
GPIO.setup(12, GPIO.OUT)

def clearLEDS():
    pixels.fill((0, 0, 0))
    pass

'''
Displays a revolving pair of lights that circle around the LED strip
'''
def indicator_led(indicate, startup):
    pixel1 = 0
    pixel2 = 1
    i = 0
    desiredRotations = 5
    if (indicate):
        while(i < (numPixels * desiredRotations - 1) ):
            clearLEDS()
            if (startup):
                pixels[pixel1] = (0, 0, 128)
                pixels[pixel2] = (0, 0, 128)
            else:
                pixels[pixel1] = (0, 128, 0)
                pixels[pixel2] = (0, 128, 0)
            pixel1 += 1
            pixel2 += 1
            i +=1

            if(pixel1 > (numPixels-1)):
                pixel1 = 0
            if(pixel2 > (numPixels-1)):
                pixel2 = 0

            time.sleep(0.1)

    else:
        clearLEDS()


def indicator_flag(indicate):
    p = GPIO.PWM(12, 50) #pin 12, 50 Hz (20ms period)
    if(indicate == True):
        p.start(7) #7% duty cycle, go to 90 degrees
    else:
        p.start(12) #12% duty cycle, go back to 180 degrees. 
    time.sleep(.02)
    p.stop()
    return FLAG
