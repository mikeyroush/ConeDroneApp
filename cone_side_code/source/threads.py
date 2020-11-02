import bluetooth
import connection

'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:

Arguments:

'''    
def listener_thread(server_sock, connections):

    print("listener thread launched")
       
    while True:
        
        # accept new connection 
        recv_sock,address = server_sock.accept()
        
        # receive incoming data 
        data = recv_sock.recv(1024)
        print(str(type(data)))
        print("received [%s]" % data)
        
        # set up reverse connection 
        send_sock = bluetooth.BluetoothSocket(bluetooth.L2CAP)
        send_sock.connect((str(address[0]), 0x1001))
        
        # send acknowledgement
        send_sock.send("acknowledged")
        
        # instantiate new connection 
        connect = connection.Connection(recv_sock, send_sock, address[0], address[1])
        
        # add connection to list
        connections.append(connect)


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
    socket recv_sock : the client socket for the specific connection we are receiving from

'''
def message_thread(recv_sock):
    
    global connections
    global reset

    







