import bluetooth
import connection
import node
import messages
import threading

'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:

Arguments:
    socket server_sock : socket we are listening for connections on 
    threading.Lock.Lock connections_lock : lock acquired when accessing the connections list
'''    
def listener_thread(server_sock, connections_lock, name, unack_msgs_lock, message_queue_lock, reset_lock):

    print("listener thread launched")
       
    while True:
        
        print("listener thread loop beginning")
        
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
        send_sock.sendall("acknowledged")
        
        # new connection name 
        new_name = "dronecone" + str(int.from_bytes(data, "big"))
        
        # instantiate new connection 
        connect = connection.Connection(recv_sock, send_sock, address[0], address[1], new_name)
        
        # create new message thread
        connect.thread = threading.Thread(target=message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
        
        # start new message thread 
        connect.thread.start()
        
        # add connection to list
        connections_lock.acquire()
        node.connections.append(connect)
        connections_lock.release()
        
        # send new node message
        print(name)
        msg_new_node = messages.craftMessage("new node", name, name2=connect.name)
        msg_num = int.from_bytes(msg_new_node[4:], "big")
        
        for conn in node.connections.copy():
            # do not send message back to whomst've just connected with us
            #if conn == connect:
            #    continue
            conn.connectionSend(msg_new_node)
            print("here")
            unack_msgs_lock.acquire()
            node.unack_msgs[(conn, msg_num, msg_new_node)] = 0
            unack_msgs_lock.release()
            print("there")
        #connections_lock.release()
        
        print("listener thread loop end")

'''
flyover_thread

Thread for sensor and indicator code. Senses flyovers, indicates, and sends successful
flyover message to other cones

Returns:

Arguments:
    threading.Lock.Lock() connections_lock : lock acquired when accessing the connections list
    threading.Lock.Lock() reset_lock : lock acquired when accessing the reset flag
    threading.Lock.Lock() unack_msgs_lock : lock acquired when accessing the unacknowledged message dictionary

'''
def flyover_thread(connections_lock, reset_lock, unack_msgs_lock):

    '''
    while True:
        reset_lock.acquire()
        if node.reset:
            # do reset stuff
            node.reset = False
            reset_lock.release()
        else:
            reset_lock.release()
            # check for indication
            if indicate:
                # create the indication message
                msg = messages.craftMessage("indicate", node.name)
                msg_num = int.from_bytes(msg[4:], "big")
                
                # tell the whole world
                connections_lock.acquire()
                for connect in node.connections:
                    connect.connectionSend(msg)
                    unack_msgs_lock.acquire()
                    node.unack_msgs[(connect, msg_num, msg)] = 0
                    unack_msgs_lock.release()
                connections.lock_release()
    '''
    while True:
        pass


'''
message_thread

Thread for receiving messages from specific nodes. Since socket.recv requires specific 
socket, each node connected to this one will have a dedicated thread for receiving 
messages. Message parsing is also done in this thread.

Returns:

Arguments:
    socket recv_sock : the client socket for the specific connection we are receiving from

'''
def message_thread(connect, connections_lock, reset_lock, unack_msgs_lock, message_queue_lock, name):
    
    #global node.unack_msgs
    
    while True:
        
        print("message thread loop beginning")
        
        # receive incoming messages
        msg = connect.recv_sock.recv(8)
        
        print("received [%s]" % msg)
        
        # parse message
        msg_type, msg_node, msg_num, _ = messages.parseMessage(msg)
        print(msg_type + " received from " + msg_node)
        
        # check if we have handled this before
        message_queue_lock.acquire()
        msg_processed = False
        for saved_msg in node.message_queue:
            # if msg_num in the queue, we have received this message before
            if saved_msg[0] == msg_num:
                # send acknowledgement
                msg_ack = messages.craftMessage("ack", name, msg_num)
                connect.connectionSend(msg_ack)  
                # we have now processed the message
                msg_processed = True
                break
            
        # if we dealt with the message, skip the rest of this
        if msg_processed:
            message_queue_lock.release()
            continue
        message_queue_lock.release()
        
        print("message thread pre processing")
        # handle message
        
        # indicate, new node, and node lost are all for the phone, never for node
        if (msg_type == "indicate" or msg_type == "new node" or msg_type == "node lost"):
            # pass it on
            #connections_lock.acquire()
            for conn in node.connections:
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                connectionSend(msg)
            #connections_lock.release()
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # could be for us, we should check
        elif (msg_type == "reset"):
            if (name == msg_node):
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
                #connections_lock.acquire()
                for conn in node.connections:
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                    connectionSend(msg)
                #conncetions_lock.release()
                
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # is for us and everyone else
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
            #connections_lock.acquire()
            for conn in node.connections:
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                connectionSend(msg)
            #conncetions_lock.release()
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # just an ack, we don't need to respond with anything
        elif (msg_type == "ack"):
            print("handling ack")
            print(len(node.unack_msgs.copy()))
            # find the message in the unacknowledged messages 
            unack_msgs_lock.acquire()
            for tup in node.unack_msgs.copy():
                print(tup)
                print(tup[0].name + " " + connect.name)
                print(str(tup[1]) + " " + msg_num)
                print(type(tup[1]))
                print(type(msg_num))
                if (tup[0].name == connect.name) and (tup[1] == msg_num):
                    print("removing ack from unack_msgs")
                    # message found, remove from dictionary
                    node.unack_msgs.pop(tup)
                    break
            unack_msgs_lock.release()
            
        else:
            # error
            print("error, could not understand msg_type")
            continue
            
        print("end of message thread loop")
        

    







