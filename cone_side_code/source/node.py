'''

This file defines the core functionality of the node, including all threads that 
are run by the node. This file is entrypoint for all of the node's code. 

'''

import bluetooth
import utils
import connection
import threading
import time
import sys
import messages
import sensor
import indicator

# global VARIABLES
address = ""            # not modified after definition
name = ""               # not modified after definition
server_port = 0x1001    # constant, port that all nodes accept connectoins on 
server_sock = None      # socket that this node accepts connections on 
connections = []        # modified
reset = False           # modified
last_reset = ""         # modified
message_queue = []      # modified 
MSG_Q_LEN = 50          # constant
unack_msgs = {}         # modified 
indicating = False      # modified

'''
main

The main execution thread for the node. After setup, this thread handles the unacknowledged messages queue.

Returns:
    None
Arguments:
    None
'''
def main():

    global message_queue
    global unack_msgs
    global connections
    
    # begin start-up indicating
    indicator.indicate(True, True)
    
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
    thread0 = threading.Thread(target=listener_thread, args=(server_sock,connections_lock,name,unack_msgs_lock,message_queue_lock,reset_lock,))

    thread1 = threading.Thread(target=flyover_thread, args=(connections_lock, reset_lock,unack_msgs_lock,))

    # declare message threads for all current connections 
    for connect in connections:
        connect.thread = threading.Thread(target=message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
    
    # start listener and flyover threads 
    thread0.start()
    thread1.start()
    
    # start message threads for all connections 
    for connect in connections:
        connect.thread.start()
    
    # stop start-up indicating
    indicator.indicate(False)
    
    # main thread becomes the thread that maintains the unack_msgs dictionary
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
                tup[0].connectionClose()
                
                # remove the current message from unack_msgs
                unack_msgs.pop(tup)
                
                # remove all messages from the removed connection in unack_msgs
                for tup2 in unack_msgs.copy():
                    if tup2[0] == tup[0]:
                        unack_msgs.pop(tup2)
                    
                # tell the phone that this connection doesn't exist any longer
                msg_node_lost = messages.craftMessage("node lost", name, name2=tup[0].name)
                msg_num = int.from_bytes(msg_node_lost[4:], "big")
                for connect in connections.copy():
                    if connect == tup[0]:
                        connections.remove(connect)
                        continue
                    connect.connectionSend(msg_node_lost)
                    unack_msgs_lock.acquire()
                    unack_msgs[(conn, msg_num, msg_node_lost)] = 0
                    unack_msgs_lock.release()
                
                continue
                
            # if the iteration value is positive and even, resend the message
            if ((unack_msgs[tup] % 2) == 0) and (unack_msgs[tup] != 0):
                # resend the message
                tup[0].connectionSend(tup[2])
            # iterate
            unack_msgs[tup] = unack_msgs[tup] + 1
        unack_msgs_lock.release()
        
        print("main thread loop end")


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
        connections.append(connect)
        connections_lock.release()
        
        # send new node message
        print(name)
        msg_new_node = messages.craftMessage("new node", name, name2=connect.name)
        msg_num = int.from_bytes(msg_new_node[4:], "big")
        
        for conn in connections.copy():
            # send the new node message
            conn.connectionSend(msg_new_node)
            
            # add to unack_msgs
            unack_msgs_lock.acquire()
            unack_msgs[(conn, msg_num, msg_new_node)] = 0
            unack_msgs_lock.release()
        
        print("listener thread loop end")

'''
flyover_thread

Thread for sensor and indicator code. Senses flyovers, indicates, and sends successful
flyover message to other cones

Returns:

Arguments:
    threading.Lock() connections_lock : lock acquired when accessing the connections list
    threading.Lock() reset_lock : lock acquired when accessing the reset flag
    threading.Lock() unack_msgs_lock : lock acquired when accessing the unacknowledged message dictionary
'''
def flyover_thread(connections_lock, reset_lock, unack_msgs_lock):

    global connections
    global unack_msgs
    global reset
    global name
    global indicating
    
    distance_arr = [False, 0]
    schedule.every(.008).seconds.do(sensor.checkSensor, distance_arr = blar)

    while True:
        reset_lock.acquire()
        
        # if we were told to reset
        if reset:
            
            # TODO: turn off lights, flag
            indicator.indicate(False)
            
            indicating = False
            # do reset stuff
            reset = False
            reset_lock.release()
            
        # if already indicating, don't worry about checking
        elif indicating:
            reset_lock.release()    
            
        # check for indication
        else:
            reset_lock.release()
            
            # check for indication
            #check if the sensor needs to be checked, if yes record values and continue
            schedule.run_pending()
            indicate, dist = sensor.checkSensor()
            
            if indicate:

                # TODO: turn on lights, flag
                indicator.indicate(True)

                # set the flag
                indicating = True
                
                # create the indication message
                msg_indicate = messages.craftMessage("indicate", name)
                msg_num = int.from_bytes(msg_indicate[4:], "big")
                
                # tell the whole world
                for connect in node.connections:
                    connect.connectionSend(msg)
                    unack_msgs_lock.acquire()
                    unack_msgs[(connect, msg_num, msg_indicate)] = 0
                    unack_msgs_lock.release()
    '''
    while True:
        pass
    '''

'''
message_thread

Thread for receiving messages from specific nodes. Since socket.recv requires specific 
socket, each node connected to this one will have a dedicated thread for receiving 
messages. Message parsing is also done in this thread.

Returns:

Arguments:
    Connection connect : connection we are handling messages from in this thread
    threading.Lock() connections_lock : lock acquired when accessing the connections list
    threading.Lock() reset_lock : lock acquired when accessing the reset flag
    threading.Lock() unack_msgs_lock : lock acquired when accessing the unacknowledged message dictionary
    threading.Lock() message_queue_lock : lock acquired when accessing the messages_queue
    string name : name of this node
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
            for conn in connections:
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                connectionSend(msg)
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # could be for us, we should check
        elif (msg_type == "reset"):
            if (name == msg_node):
                # it's for you
                reset_lock.acquire()
                if not reset:
                    if (last_reset != msg_num):
                        # set the reset flag to true
                        reset = True
                        # record that we reset on this msg's number
                        # this will save us trouble if the sensor thread handles the reset 
                        #   before all nodes have processed the reset 
                        #   ( *** not sure this is an actual case that could occur ***)
                        last_reset = msg_num
                reset_lock.release()
                
            else:
                # pass it on
                for conn in connections:
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                    
                    # send message
                    connectionSend(msg)
                
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # is for us and everyone else
        elif (msg_type == "reset all"):
            reset_lock.acquire()
            if not reset:
                if (last_reset != msg_num):
                    # set the reset flag to true
                    reset = True
                    # record that we reset on this msg's number
                    # this will save us trouble if the sensor thread handles the reset 
                    #   before all nodes have processed the reset 
                    #   ( *** not sure this is an actual case that could occur ***)
                    last_reset = msg_num
            reset_lock.release()
            
            #  pass message on 
            for conn in connections:
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                connectionSend(msg)
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # just an ack, we don't need to respond with anything
        elif (msg_type == "ack"):
            print("handling ack")
            # find the message in the unacknowledged messages 
            unack_msgs_lock.acquire()
            for tup in unack_msgs.copy():
                if (tup[0].name == connect.name) and (str(tup[1]) == msg_num):
                    print("removing ack from unack_msgs")
                    # message found, remove from dictionary
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



