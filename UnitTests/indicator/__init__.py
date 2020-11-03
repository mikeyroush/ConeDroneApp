import board
import neopixel
from time import sleep

# Using GPIO 18 (PCM CLK) for the data line for the LEDS
# Second argument is for the number of LEDS we want to control
pixels = neopixel.NeoPixel(board.D18, 3)

def indicator_led(indicate):
	if(indicate):
		pixels.fill((0,0,128)) # Currently setting the LEDs to be blue at half brightness
		return True
	else:
		pixels.fill((0,0,0))
		return False

# Just to have a dedicated function to clear the LEDs
def clearLEDS():
	pixels.fill((0,0,0))

def indicator_flag(indicate):
	if(indicate==True):
		FLAG = 1
	else:
		FLAG = 0
	return FLAG

