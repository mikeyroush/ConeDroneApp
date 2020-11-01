'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:

Arguments:

'''    
def listener_thread():
    
    global connections
    
    while True:
        time.sleep(5)


'''
flyover_thread

Thread for sensor and indicator code. Senses flyovers, indicates, and sends successful
flyover message to other cones

Returns:

Arguments:

'''
def flyover_thread():

    global connections
    global reset
    
    while True:
        time.sleep(5)


'''
message_thread

Thread for receiving messages from specific nodes. Since socket.recv requires specific 
socket, each node connected to this one will have a dedicated thread for receiving 
messages. Message parsing is also done in this thread.

Returns:

Arguments:

'''
def message_thread(recv_sock):
    
    global connections
    global reset
