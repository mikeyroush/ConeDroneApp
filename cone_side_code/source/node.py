'''

This file defines the core functionality of the node. This file is entrypoint
for all of the node's code. 

'''

import bluetooth
import utils
import connection
import threading
import threads

# LOCAL VARIABLES
address = ""
name = ""
#not sure that we will need this
#uuid = ""
server_port = 0x1001    # port that all nodes accept connections on 
server_sock = None      # socket that this node accepts connections on 
connections = []
reset = False
last_reset = ""
message_queue = []


def main():
    
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
            (recv_sock,send_sock,address,port) = utils.establishConnection(address, server_sock)
            connect = connection.Connection(recv_sock, send_sock, address, port)
            connections.append(connect)

    reset_lock = threading.Lock.Lock()
    connections_lock = threading.Lock.Lock()
    message_queue_lock = threading.Lock.Lock()

    # declare listener and flyover thread 
    thread0 = threading.Thread(target=threads.listener_thread, args=(server_sock,connections_lock,))
    thread1 = threading.Thread(target=threads.flyover_thread, (connections_lock, ))
    
    # declare message threads for all current connections 
    for connection in Connections:
        connection.thread = threading.Thread(target=threads.message_thread, (connection.sock, connections_lock, reset_lock,))
    
    # start listener and flyover threads 
    thread0.start()
    thread1.start()
    
    # start message threads for all connections 
    for connection in Connections:
        connection.thread.start()

    # loop forever
    # I'm not sure if I can let the main thread finish or not, since the global variables
    #   are defined here
    while True:
        pass


if __name__ == "__main__":
    main()



