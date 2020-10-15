
import keyboard
from bluetooth import *


def establishConnection():
    server_socket = BluetoothSocket(RFCOMM)
    server_socket.bind(("",3))
    server_socket.listen(1)
    print("Ready to accept")
    client_socket, address = server_socket.accept()
    data = client_socket.recv(1024)
    
    print(data)
    
    client_socket.close()
    server_socket.close()
    return 0

def sendStatus(status):
    return 0    

def readReset():
    return keyboard.is_pressed('r') 


#establishConnection()
from bluedot import BlueDot
bd = BlueDot()
bd.wait_for_press()
print("Pressed")
