'''

This file defines the core functionality of the node. This file is entrypoint
for all of the node's code. 

'''

import bluetooth
import utils
import connection
import threading
import threads
import time
import sys
import messages

# LOCAL VARIABLES
address = ""
name = ""
#not sure that we will need this
#uuid = ""
server_port = 0x1001    # port that all nodes accept connectoins on 
server_sock = None      # socket that this node accepts connections on 
connections = []
reset = False
last_reset = ""
message_queue = []
MSG_Q_LEN = 50
unack_msgs = {}


def main():
    
    # make sure hci0 is up
    code = utils.enableBluetooth()
    
    # check for error in bringing up hci0
    if code:
        print("error, couldn't enable bluetooth")
        print("did you forget to run as root?")
        sys.exit("Could not bring up hci0")
    
    # define address variable
    address = utils.getBDaddr()
    print("address is " + address)
    
    # define name variable
    name = utils.getName()
    print("name is " + name)
    
    # set up server socket
    server_sock = utils.establishServerSock(server_port)
    print("server sock set up")
    
    # scan for other nodes
    target_addresses = utils.nodeScan()
    print("found " + str(len(target_addresses)) + " addresses")
    
    # for every address we discovered, set up the connection and reverse connection 
    if target_addresses:
        for address in target_addresses:
            print("establishing connection with " + address)
            (recv_sock,send_sock,address,port) = utils.establishConnection(address, server_sock, name)
            connect = connection.Connection(recv_sock, send_sock, address, port, name)
            connections.append(connect)

    # locks for synchronization
    reset_lock = threading.Lock()
    connections_lock = threading.Lock()
    message_queue_lock = threading.Lock()
    unack_msgs_lock = threading.Lock()

    # declare listener and flyover thread 
    thread0 = threading.Thread(target=threads.listener_thread, args=(server_sock,connections_lock,name,unack_msgs_lock,))
    thread1 = threading.Thread(target=threads.flyover_thread, args=(connections_lock, reset_lock,unack_msgs_lock,))
    
    # declare message threads for all current connections 
    for connect in connections:
        connect.thread = threading.Thread(target=threads.message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
    
    # start listener and flyover threads 
    thread0.start()
    thread1.start()
    
    # start message threads for all connections 
    for connect in connections:
        connect.thread.start()

    # loop forever
    # I'm not sure if I can let the main thread finish or not, since the global variables
    #   are defined here
    while True:
        time.sleep(3)
        
        # iterate unack messages
        unack_msgs_lock.acquire()
        for tup in unack_msgs.copy():
            print(tup)
            # if the iteration value is 10, we have lost the node
            if (unack_msgs[tup] == 10):
                # close the connection
                print("node is lost: " + tup[0].name)
                #connections_lock.acquire()
                tup[0].connectionClose()
                #connections_lock.release()
                
                # remove the current message from unack_msgs
                unack_msgs.pop(tup)
                
                # remove all messages from the removed connection in unack_msgs
                for tup2 in unack_msgs.copy():
                    if tup2[0] == tup[0]:
                        unack_msgs.pop(tup2)
                    
                # tell the phone that this connection doesn't exist any longer
                msg_node_lost = messages.craftMessage("node lost", address, name2=tup[0].addr)
                #connections_lock.acquire()
                #for connect in connections.copy():
                for connect in connections:
                    connect.connectionSend(msg_node_lost)
                #connections_lock.release()
            # if the iteration value is positive and even, resend the message
            if ((unack_msgs[tup] % 2) == 0) and (unack_msgs[tup] != 0):
                # resend the message
                tup[0].connectionSend(tup[2])
            # iterate
            unack_msgs[tup] = unack_msgs[tup] + 1
        unack_msgs_lock.release()


if __name__ == "__main__":
    main()



