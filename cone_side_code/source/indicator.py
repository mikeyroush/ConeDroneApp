import time
import board
import neopixel
import sys
import signal
import RPi.GPIO as GPIO
import threading 

numPixels = 30
pixels = neopixel.NeoPixel(board.D21, numPixels) #Connected to GPIO 21
SERVO_PWM = 12 

#setup, initialization
GPIO.setmode(GPIO.BCM)
GPIO.setup(SERVO_PWM, GPIO.OUT)
indicate_lock = threading.Lock()
indicate_lock.acquire()

def clearLEDS():
    pixels.fill((0, 0, 0))
    pass
    
def lowerFlag():
    p = GPIO.PWM(SERVO_PWM, 50)
    p.start(12)
    time.sleep(.01)

'''
Displays a revolving pair of lights that circle around the LED strip
'''
def indicatorThread(startup, lock):
    p = GPIO.PWM(SERVO_PWM, 50)
    pixel1 = 0
    pixel2 = 1
    
    #put the flag up
    p.start(7)
    time.sleep(0.05)
    p.stop()
    
    #start and maintain the LED pattern until our lock is locked.
    while(not lock.locked() ):
        clearLEDS()
        if (startup):
            pixels[pixel1] = (0, 0, 128)
            pixels[pixel2] = (0, 0, 128)
        else:
            pixels[pixel1] = (0, 128, 0)
            pixels[pixel2] = (0, 128, 0)
        pixel1 += 1
        pixel2 += 1

        if(pixel1 > (numPixels-1)):
            pixel1 = 0
        if(pixel2 > (numPixels-1)):
            pixel2 = 0

        time.sleep(0.1)
    return
    

def indicatorStart(startup):
    if (not indicate_lock.locked()):
        print("already indicating")
        return

    indicate_lock.release()
    inner_thread = threading.Thread(target=indicatorThread, args=(startup, indicate_lock))
    inner_thread.start()
    
#stop the inner_thread loop, lower the flag, and clear the LEDs. 
def indicatorStop():
    if (indicate_lock.locked()):
        print("already not indicating")
        return

    indicate_lock.acquire()
    p = GPIO.PWM(SERVO_PWM, 50)
    p.start(12) #12% duty cycle, go back to 180 degrees. 
    p.ChangeDutyCycle(12)
    time.sleep(.01)
    p.stop()
    clearLEDS()
