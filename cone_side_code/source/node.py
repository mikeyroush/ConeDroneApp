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
#not sure that we will need this
#uuid = ""
server_port = 0x1001    # port that all nodes accept connectoins on 
server_sock = None      # socket that this node accepts connections on 

# SHARED VARIABLES
connections = []
reset = False

def main():
    
    # define address variable
    address = utils.getBDaddr()
    
    # set up server socket
    server_sock = utils.establishServerSock(server_port)
    
    # scan for other nodes
    target_addresses = utils.nodeScan()
    
    # for every address we discovered, set up the connection and reverse connection 
    if target_addresses:
        for address in target_addresses:
            (recv_sock,address,port) = utils.establishConnection(address)
            connection = Connection(recv_sock, address, port)
            connections.append(connection)

    # declare listener and flyover thread 
    thread0 = threading.Thread(target=threads.listener_thread, ())
    thread1 = threading.Thread(target=threads.flyover_thread, ())
    
    # declare message threads for all current connections 
    for connection in Connections:
        connection.thread = threading.Thread(target=threads.message_thread, (connection.sock))
    
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



