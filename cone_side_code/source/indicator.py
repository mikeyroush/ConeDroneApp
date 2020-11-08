import board
from time import sleep
import neopixel
import sys
import signal

numPixels = 10
pixels = neopixel.NeoPixel(board.D18, numPixels)

def clearLEDS():
    pixels.fill((0, 0, 0))
    pass

'''
Displays a revolving pair of lights that circle around the LED strip
'''
def indicator_led(indicate):
    if (indicate):
        pixel1 = 0
        pixel2 = 1

        while(True):
            clearLEDS()
            pixels[pixel1] = (0, 0, 128)
            pixels[pixel2] = (0, 0, 128)
            pixel1 += 1
            pixel2 += 1

            if(pixel1 > (numPixels-1)):
                pixel1 = 0
            if(pixel2 > (numPixels-1)):
                pixel2 = 0

            sleep(0.1)

    else:
        clearLEDS()


def indicator_flag(indicate):
    if(indicate == True):
        FLAG = 1
    else:
        FLAG = 0
    return FLAG
