'''

This file defines utility functions, including functions that issue system calls on the
Raspberry Pi. 

'''

import os
import sys
import bluetooth
import re

'''
enableBluetooth

Bring up hci0

Returns:
    int code : error code returned by command
Arguments:
    None
'''
def enableBluetooth():
    code = os.system("hciconfig hci0 up 2>/dev/null")
    return code

'''
getBDaddr 

Get the Raspberry Pi's BD address

Returns: 
    string addr : BD address of Raspberry Pi
Arguments: 
    None
'''
def getBDaddr():
	addr = os.popen("hciconfig | awk '/BD Address:/ {print $3}'").read().rstrip()
	return addr


'''
getName

Get the hostname of the Raspberry Pi -- should be "dronecone" and then a three digit number

Returns:
    string name : hostname of Raspberry Pi
Arguments:
    None
'''
def getName():
    name = os.popen("hostname").read().rstrip()
    

'''
nodeScan

Create list of discovered node addresses

Returns:
    list target_addresses : discovered node addresses
Arguments:
    None
'''
def nodeScan():
    target_addresses = []
    target_name_pattern = re.compile("^chris*")
    #target_name_pattern = re.compile("^dronecone*")

    nearby_devices = bluetooth.discover_devices()

    for bdaddr in nearby_devices:
        if target_name_pattern.match(bluetooth.lookup_name(bdaddr)):
            target_addresses.append(bdaddr)

    if not target_addresses:
        print("no devices found")
    else:
        print("found " + str(len(target_addresses)) + " devices")
        for address in target_addresses:
            print(address + " : " + bluetooth.lookup_name(address))
    
    return target_addresses


'''
establishServerSock

Creates the socket this node will accept connections on 

Returns:

Arguments:

'''
def establishServerSock(server_port):
    
    server_sock = bluetooth.BluetoothSocket(bluetooth.L2CAP)
    server_sock.bind(("", server_port))
    server_sock.listen(1)
    return server_sock


'''
establishConnection

Establish a connection with an address, as well as the reverse connection 

Returns:

Arguments:

'''
def establishConnection(address, server_sock, name):
    
    # set up the socket we will use to connect 
    send_sock = bluetooth.BluetoothSocket(bluetooth.L2CAP)
    
    # server port on other node -- this is standard
    port = 0x1001
    
    # connect to other node 
    send_sock.connect((address, port))
    
    # introduce yourself
    send_sock.sendall(name)
    
    # accept reverse connection
    recv_sock,address = server_sock.accept()
    
    # receive acknowledgement
    ack = recv_sock.recv(1024)
    print("received [%s]" % ack)
    
    return (recv_sock, send_sock, address[0], address[1])












