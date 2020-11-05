'''

This file defines the core functionality of the node. This file is entrypoint
for all of the node's code. 

'''

import bluetooth
import utils
import connection
import threading
#import threads
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

    global message_queue
    global unack_msgs
    global connections
    
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
    #thread0 = threading.Thread(target=threads.listener_thread, args=(server_sock,connections_lock,name,unack_msgs_lock,message_queue_lock,reset_lock,))
    thread0 = threading.Thread(target=listener_thread, args=(server_sock,connections_lock,name,unack_msgs_lock,message_queue_lock,reset_lock,))

    #thread1 = threading.Thread(target=threads.flyover_thread, args=(connections_lock, reset_lock,unack_msgs_lock,))
    thread1 = threading.Thread(target=flyover_thread, args=(connections_lock, reset_lock,unack_msgs_lock,))

    # declare message threads for all current connections 
    for connect in connections:
        #connect.thread = threading.Thread(target=threads.message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
        connect.thread = threading.Thread(target=message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
    
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
                msg_node_lost = messages.craftMessage("node lost", name, name2=tup[0].name)
                msg_num = int.from_bytes(msg_node_lost[4:], "big")
                #connections_lock.acquire()
                #for connect in connections.copy():
                for connect in connections.copy():
                    if connect == tup[0]:
                        connections.remove(connect)
                        continue
                    connect.connectionSend(msg_node_lost)
                    unack_msgs_lock.acquire()
                    #node.unack_msgs[(conn, msg_num, msg_new_node)] = 0
                    unack_msgs[(conn, msg_num, msg_node_lost)] = 0
                    unack_msgs_lock.release()
                
                continue
                #connections_lock.release()
            # if the iteration value is positive and even, resend the message
            if ((unack_msgs[tup] % 2) == 0) and (unack_msgs[tup] != 0):
                # resend the message
                tup[0].connectionSend(tup[2])
            # iterate
            unack_msgs[tup] = unack_msgs[tup] + 1
        unack_msgs_lock.release()
        
        print("main thread loop end")







# this might get deleted
'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:

Arguments:
    socket server_sock : socket we are listening for connections on 
    threading.Lock.Lock connections_lock : lock acquired when accessing the connections list
'''    
def listener_thread(server_sock, connections_lock, name, unack_msgs_lock, message_queue_lock, reset_lock):

    global message_queue
    global unack_msgs
    global reset
    global last_reset
    global connections

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
        #node.connections.append(connect)
        connections.append(connect)
        connections_lock.release()
        
        # send new node message
        print(name)
        msg_new_node = messages.craftMessage("new node", name, name2=connect.name)
        msg_num = int.from_bytes(msg_new_node[4:], "big")
        
        #for conn in node.connections.copy():
        for conn in connections.copy():
            # do not send message back to whomst've just connected with us
            #if conn == connect:
            #    continue
            conn.connectionSend(msg_new_node)
            unack_msgs_lock.acquire()
            #node.unack_msgs[(conn, msg_num, msg_new_node)] = 0
            unack_msgs[(conn, msg_num, msg_new_node)] = 0
            unack_msgs_lock.release()
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
    
    global unack_msgs
    global message_queue
    global connections
    global reset
    global last_reset
    
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
        #for saved_msg in node.message_queue:
        for saved_msg in message_queue:    
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
            #for conn in node.connections:
            for conn in connections:
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
                #if not node.reset:
                if not reset:
                    #if (node.last_reset != msg_num):
                    if (last_reset != msg_num):
                        # set the reset flag to true
                        #node.reset = True
                        reset = True
                        # record that we reset on this msg's number
                        # this will save us trouble if the sensor thread handles the reset 
                        #   before all nodes have processed the reset 
                        #   ( *** not sure this is an actual case that could occur ***)
                        #node.last_reset = msg_num
                        last_reset = msg_num
                reset_lock.release()
                
            else:
                # pass it on
                #connections_lock.acquire()
                #for conn in node.connections:
                for conn in connections:
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
            #if not node.reset:
            if not reset:
                #if (node.last_reset != msg_num):
                if (last_reset != msg_num):
                    # set the reset flag to true
                    #node.reset = True
                    reset = True
                    # record that we reset on this msg's number
                    # this will save us trouble if the sensor thread handles the reset 
                    #   before all nodes have processed the reset 
                    #   ( *** not sure this is an actual case that could occur ***)
                    #node.last_reset = msg_num
                    last_reset = msg_num
            reset_lock.release()
            
            #  pass message on 
            #connections_lock.acquire()
            for conn in connections:
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
            # find the message in the unacknowledged messages 
            unack_msgs_lock.acquire()
            #for tup in node.unack_msgs.copy():
            for tup in unack_msgs.copy():
                if (tup[0].name == connect.name) and (str(tup[1]) == msg_num):
                    print("removing ack from unack_msgs")
                    # message found, remove from dictionary
                    #node.unack_msgs.pop(tup)
                    unack_msgs.pop(tup)
                    break
            unack_msgs_lock.release()
            
        else:
            # error
            print("error, could not understand msg_type")
            continue
            
        print("end of message thread loop")
        







if __name__ == "__main__":
    main()



