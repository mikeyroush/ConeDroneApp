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
    code = os.system("hciconfig hci0 up piscan sspmode 1 2>/dev/null")
    return code

'''

'''
def enablePairing():
    code = os.system("/usr/share/doc/bluez-test-scripts/examples/simple-agent -c NoInputNoOutput &" )
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
    return name 
    

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
    #target_name_pattern = re.compile("^chris*")
    target_name_pattern = re.compile("^dronecone*")

    nearby_devices = bluetooth.discover_devices()

    for bdaddr in nearby_devices:
        print(bluetooth.lookup_name(bdaddr))
        type(bluetooth.lookup_name(bdaddr))
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
    bluetooth.BluetoothSocket server_socket : bluetooth socket on this node that we listen for connections with
Arguments:
    int server_port : port on this device that we will bind our server socket to

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
    bluetooth.BluetoothSocket recv_sock, : bluetooth socket on other node that we are receiving messages from for this connection on
    bluetooth.BluetoothSocket send_sock, : bluetooth socket on this node that we are sending messages from for this connection on 
    string address[0] : MAC address of the node we are connecting to
    string address[1] : port of the other node's server socket
Arguments:
    string address : MAC address of the node we are connecting to
    bluetooth.bluetoothSocket server_sock : socket on this node that we listen for connections with
    string name : name of this node

'''
def establishConnection(address, server_sock, name):
    
    # set up the socket we will use to connect 
    send_sock = bluetooth.BluetoothSocket(bluetooth.L2CAP)
    
    # server port on other node -- this is standard
    port = 0x1001
        
    # connect to other node 
    send_sock.connect((address, port))
    
    # introduce yourself
    send_sock.sendall(int(name[9:]).to_bytes(8, "big"))
    
    # accept reverse connection
    recv_sock,address = server_sock.accept()
    
    # receive acknowledgement
    ack = recv_sock.recv(8)
    
    return (recv_sock, send_sock, address[0], address[1])












