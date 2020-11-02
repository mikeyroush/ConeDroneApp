import bluetooth
import connection
import node
import messages

'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:

Arguments:

'''    
def listener_thread(server_sock, connections_lock):

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
        node.connections.append(connect)


'''
flyover_thread

Thread for sensor and indicator code. Senses flyovers, indicates, and sends successful
flyover message to other cones

Returns:

Arguments:

'''
def flyover_thread():

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
def message_thread(recv_sock, connections_lock, reset_lock):
    
    while True:
        
        # receive incoming messages
        msg = recv_sock.recv(8)
        
        # parse message
        (msg_type, msg_node, msg_num) = messages.parseMessage(msg)
        print(msg_type + " received from dronecone" + msg_node)
        
        # check if we have handled this before
        node.message_queue_lock.acquire()
        if msg_num in node.message_queue:
            # we already took care of this message, don't worry about it
            node.message_queue_lock.release()
            continue
        node.message_queue_lock.release()
        
        # handle message
        if (msg_type == ("indicate" || "new node" || "node lost")):
            # pass it on
        elif (msg_type == "reset"):
            if (node.name == msg_node):
                # it's for you
                reset_lock.acquire()
                if not node.reset:
                    if (node.last_reset != msg_num):
                        # set the reset flag to true
                        node.reset = True
                        # record that we reset on this msg's number
                        # this will save us trouble if the sensor thread handles the reset 
                        #   before all nodes have processed the reset 
                        #   ( *** not sure this is an actual case that could occur ***)
                        node.last_reset = msg_num
                reset_lock.release()
            else:
                # pass it on
        elif (msg_type == "reset all"):
            reset_lock.acquire()
            if not node.reset:
                if (node.last_reset != msg_num):
                    # set the reset flag to true
                    node.reset = True
                    # record that we reset on this msg's number
                    # this will save us trouble if the sensor thread handles the reset 
                    #   before all nodes have processed the reset 
                    #   ( *** not sure this is an actual case that could occur ***)
                    node.last_reset = msg_num
            reset_lock.release()
            #  pass message on 
        else:
            # error
            print("error, could not understand msg_type")
            continue
            
        # update message queue
        node.message_queue_lock.acquire()
        if len(node.message_queue) == 50:
            node.message_queue.pop(0)
        if not msg_num in node.message_queue:
            node.message_queue.append(msg_num)
        node.message_queue_lock.release()
        
        

    







