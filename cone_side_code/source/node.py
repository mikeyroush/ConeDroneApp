'''

This file defines the core functionality of the node, including all threads that 
are run by the node. This file is entrypoint for all of the node's code. 

'''

import bluetooth
import utils
import connection
import threading
import time
import os
import sys
import messages
import sensor
import indicator
import schedule

# global VARIABLES
address = ""                # not modified after definition
name = ""                   # not modified after definition
server_port = 0x1001        # constant, port that all nodes accept connections on 
server_sock = None          # socket that this node accepts connections on 
connections = []            # modified
reset = False               # modified
last_reset = ""             # modified
message_queue = []          # modified 
MSG_Q_LEN = 50              # constant
unack_msgs = {}             # modified 
indicating = False          # modified
do_phone_discover = True    # modified
phone_connection = None     # modified
phone_server_sock = None    # modified
phone_client_sock = None    # modified

'''
main

The main execution thread for the node. After setup, this thread handles the unacknowledged messages queue.

Returns:
    None
Arguments:
    None
'''
def main():

    # global variables
    global message_queue
    global unack_msgs
    global connections
    global name
    global do_phone_discover
    
    # begin start-up indication (blue lights and flag)
    indicator.indicatorStart(True)
    
    # make sure hci0 is up
    code = utils.enableBluetooth()
    
    # check for error in bringing up hci0
    if code:
        print("error, couldn't enable bluetooth")
        print("did you forget to run as root?")
        sys.exit("Could not bring up hci0")
    
    # make sure we are pairable
    code = utils.enablePairing()
    
    # check for error in bringing up hci0
    if code:
        print("error, couldn't enable bluetooth pairing")
        print("did you forget to run as root?")
        sys.exit("Could not enable pairing")
    
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
    
    # for every address we discovered, set up the connection and reverse connection 
    if target_addresses:
        for address in target_addresses:
            print("establishing connection with " + address)
            (recv_sock,send_sock,address,port) = utils.establishConnection(address, server_sock, name)
            connect = connection.Connection(recv_sock, send_sock, address, port, name)
            connections.append(connect)

    # locks for synchronization
    reset_lock = threading.Lock()           # used when modifying the reset flag
    connections_lock = threading.Lock()     # used when modifying the connections list
    message_queue_lock = threading.Lock()   # used when modifying the message queue
    unack_msgs_lock = threading.Lock()      # used when modifying the unacknowledged message dictionary

    # start listening for a phone connection
    phone_listener_thread = threading.Thread(target=phoneListenerThread, args=(connections_lock,reset_lock,unack_msgs_lock,message_queue_lock,))
    phone_listener_thread.start()

    # declare listener and flyover thread 
    thread0 = threading.Thread(target=listener_thread, args=(server_sock,connections_lock,name,unack_msgs_lock,message_queue_lock,reset_lock,))
    thread1 = threading.Thread(target=flyover_thread, args=(connections_lock,reset_lock,unack_msgs_lock,message_queue_lock,))

    # declare message threads for all current connections 
    for connect in connections:
        connect.thread = threading.Thread(target=message_thread, args=(connect, connections_lock, reset_lock,unack_msgs_lock,message_queue_lock,name,))
    
    # start listener and flyover threads 
    thread0.start()
    thread1.start()
    
    # start message threads for all connections 
    for connect in connections:
        connect.thread.start()
    
    # stop start-up indication
    indicator.indicatorStop()
    
    # main thread becomes the thread that maintains the unack_msgs dictionary
    while True:
    
        # give it some time
        time.sleep(3)
        
        # iterate unack messages
        unack_msgs_copy = unack_msgs.copy()
        for tup in unack_msgs_copy:
            print(tup)
            # if we have sent the message five times with no ack, we have lost the node
            if (unack_msgs_copy[tup] == 10):
                # close the connection
                print("node is lost: " + tup[0].name)
                tup[0].connectionClose()
                
                # remove the current message from unack_msgs
                unack_msgs_lock.acquire()
                try:
                    unack_msgs.pop(tup)
                except KeyError as e:
                    print(e)
                    print("unack message already removed")
                unack_msgs_lock.release()
                
                # remove all messages from the removed connection in unack_msgs
                for tup2 in unack_msgs_copy:
                    if tup2[0] == tup[0]:
                        unack_msgs_lock.acquire()
                        try:
                            unack_msgs.pop(tup2)
                        except KeyError as e:
                            print(e)
                            print("unack message already removed")
                        unack_msgs_lock.release()
                    
                # tell the phone that this connection doesn't exist any longer
                msg_node_lost = messages.craftMessage("node lost", name, name2=tup[0].name)
                msg_num = int.from_bytes(msg_node_lost[4:], "big")
                
                # update the message queue with the message we are sending now
                message_queue_lock.acquire()
                if len(message_queue) == MSG_Q_LEN:
                    message_queue.pop(0)
                message_queue.append(msg_num)
                message_queue_lock.release()
                
                # remove connection from connections
                connections_lock.acquire()
                try:
                    connections.remove(tup[0])
                except ValueError as e:
                    print(e)
                    print("connection already removed")
                connections_lock.release()
                
                # if we have the phone, just send to the phone
                if phone_connection:
                    # send the node lost message
                    phone_connection.connectionSend(msg_node_lost)
                    
                    # add to unack_msgs
                    unack_msgs_lock.acquire()
                    unack_msgs[(phone_connection, msg_num, msg_node_lost)] = 0
                    unack_msgs_lock.release()
                
                # send to every connection we have 
                else:
                    for connect in connections.copy():
                        # send the node lost message
                        connect.connectionSend(msg_node_lost)

                        # add to unack_msgs
                        unack_msgs_lock.acquire()
                        unack_msgs[(conn, msg_num, msg_node_lost)] = 0
                        unack_msgs_lock.release()
                
                continue
                
            # if the iteration value is positive and even, resend the message
            if ((unack_msgs_copy[tup] % 2) == 0) and (unack_msgs_copy[tup] != 0):
                # resend the message
                tup[0].connectionSend(tup[2])
            # iterate
            unack_msgs_lock.acquire()
            try:
                unack_msgs[tup] = unack_msgs[tup] + 1
            except KeyError as e:
                print(e)
                print("already removed from unack_msgs")
            unack_msgs_lock.release()
        
        print("main thread loop end")
        

'''
listener_thread

Thread that listens for and accepts new connections, and sets up reverse connection.

Returns:
    None
Arguments:
    socket server_sock : socket we are listening for connections on 
    threading.Lock.Lock connections_lock : lock acquired when accessing the connections list
'''    
def listener_thread(server_sock, connections_lock, name, unack_msgs_lock, message_queue_lock, reset_lock):

    # global variables
    global message_queue
    global unack_msgs
    global reset
    global last_reset
    global connections
    global phone_connection

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
        
        # create ack message
        ack_int = int(name[9:])      
        
        # send acknowledgement
        send_sock.sendall(ack_int.to_bytes(8, "big"))
        
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
        
        # update the message queue with the message we are sending now
        message_queue_lock.acquire()
        if len(message_queue) == MSG_Q_LEN:
            message_queue.pop(0)
        message_queue.append(msg_num)
        message_queue_lock.release()
        
        # if we have the phone, just send to the phone
        if phone_connection:
            # send the new node message
            phone_connection.connectionSend(msg_new_node)
            
            # add to unack_msgs
            unack_msgs_lock.acquire()
            unack_msgs[(phone_connection, msg_num, msg_new_node)] = 0
            unack_msgs_lock.release()
            
        # send to every connection we have 
        else:
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
    None
Arguments:
    threading.Lock() connections_lock : lock acquired when accessing the connections list
    threading.Lock() reset_lock : lock acquired when accessing the reset flag
    threading.Lock() unack_msgs_lock : lock acquired when accessing the unacknowledged message dictionary
'''
def flyover_thread(connections_lock, reset_lock, unack_msgs_lock, message_queue_lock):

    # global variables
    global connections
    global unack_msgs
    global reset
    global name
    global indicating
    
    distance_arr = [False, 0]
    schedule.every(.008).seconds.do(sensor.checkSensor, distance_arr)

    while True:
        reset_lock.acquire()
        
        # if we were told to reset
        if reset:
            
            indicator.indicatorStop()
            
            print("here")
            
            # do reset stuff
            reset = False
            indicating = False
            reset_lock.release()
            
        # if already indicating, don't worry about checking
        elif indicating:
            reset_lock.release()    
            
        # check for flyovers
        else:
            reset_lock.release()
            
            # check for indication
            #check if the sensor needs to be checked, if yes record values and continue
            
            schedule.run_pending()
            [indicate, dist] = distance_arr #distance_arr is set by the schedule sensor job
            
            if indicate:
                indicator.indicatorStart(False)

                # create the indication message
                msg_indicating = messages.craftMessage("indicating", name)
                msg_num = int.from_bytes(msg_indicating[4:], "big")
                
                # update the message queue with the message we are sending now
                message_queue_lock.acquire()
                if len(message_queue) == MSG_Q_LEN:
                    message_queue.pop(0)
                message_queue.append(msg_num)
                message_queue_lock.release()
                
                # if we have the phone, just send to the phone
                if phone_connection:
                    # send the indicating message
                    phone_connection.connectionSend(msg_indicating)
                    
                    # add to unack_msgs
                    unack_msgs_lock.acquire()
                    unack_msgs[(phone_connection, msg_num, msg_indicating)] = 0
                    unack_msgs_lock.release()
                
                # send to every connection we have 
                else:
                    # tell the whole world
                    for connect in connections.copy():
                        # send the indicating message
                        connect.connectionSend(msg_indicating)
                        
                        # add to unack_msgs
                        unack_msgs_lock.acquire()
                        unack_msgs[(connect, msg_num, msg_indicating)] = 0
                        unack_msgs_lock.release()
                    
                indicating = True
                    
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
    
    # global variables
    global unack_msgs
    global message_queue
    global connections
    global reset
    global last_reset
    global do_phone_discover	
    global phone_connection
    global MSG_Q_LEN
    global indicating
    
    while True:
        
        print("message thread loop beginning")
        
        connection_lost = False
        
        # receive incoming messages
        try:
            msg = connect.recv_sock.recv(8)
        except Exception as e:
            print(e)
            connection_lost = True
        
        print("received [%s]" % msg)
        
        # if the socket disconnected
        if (len(msg) == 0) or connection_lost:
            print("connection lost")
            
            # close the connection
            connect.connectionClose()
            
            # remove all messages from the removed connection in unack_msgs
            unack_msgs_lock.acquire()
            for tup in unack_msgs.copy():
                if tup[0] == connect:
                    try:
                        unack_msgs.pop(tup)
                    except KeyError as e:
                        print(e)
                        print("unack message already removed")
            unack_msgs_lock.release()
            
            # if this is not the phone connection
            if connect.name != "PHONE":
                # craft the node lost message
                msg_node_lost = messages.craftMessage("node lost", name, name2=connect.name)
                msg_num = int.from_bytes(msg_node_lost[4:], "big")
                
                # update the message queue with the message we are sending now
                message_queue_lock.acquire()
                if len(message_queue) == MSG_Q_LEN:
                    message_queue.pop(0)
                message_queue.append(msg_num)
                message_queue_lock.release()
                
                # remove connection from connections
                connections_lock.acquire()
                try:
                    connections.remove(connect)
                except ValueError as e:
                    print(e)
                    print("connection already removed")
                connections_lock.release()
                
                # if we have the phone, just send to the phone
                if phone_connection:
                    # send the node lost message
                    phone_connection.connectionSend(msg_node_lost)
                    
                    # add to unack_msgs
                    unack_msgs_lock.acquire()
                    unack_msgs[(phone_connection, msg_num, msg_node_lost)] = 0
                    unack_msgs_lock.release()
                    
                # send to every connection we have 
                else:
                    for conn in connections.copy():
                        
                        # send the node lost message
                        conn.connectionSend(msg_node_lost)
                        
                        # add to unack_msgs
                        unack_msgs_lock.acquire()
                        unack_msgs[(conn, msg_num, msg_node_lost)] = 0
                        unack_msgs_lock.release()
            else:
                # restart the phone listener thread
                phone_listener_thread = threading.Thread(target=phoneListenerThread, args=(connections_lock,reset_lock,unack_msgs_lock,message_queue_lock,))
                phone_listener_thread.start()
            
            break
        
        # parse message
        msg_type, msg_node, msg_num, _ = messages.parseMessage(msg)
        print(msg_type + " received from " + connect.name)
        
        # check if we have handled this before
        message_queue_lock.acquire()
        msg_processed = False
        for saved_msg in message_queue:    
            # if msg_num in the queue, we have received this message before
            if saved_msg == msg_num:
                # don't ack acks
                if (msg_type == "ack"):
                    #msg_processed = True
                    break
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
        
        # we haven't dealt with message before, add to the queue
        if len(message_queue) == MSG_Q_LEN:
            message_queue.pop(0)
        print("adding message to queue")
        message_queue.append(msg_num)
        message_queue_lock.release()
        
        print("message thread pre processing")
        # handle message
        
        # indicate, new node, and node lost are all for the phone, never for node
        if (msg_type == "indicating" or msg_type == "new node" or msg_type == "node lost" or msg_type == "id"):
            # do we have the phone?
            if phone_connection:
                # send message to the phone
                phone_connection.connectionSend(msg)
                
                unack_msgs_lock.acquire()
                unack_msgs[(phone_connection, msg_num, msg)] = 0
                unack_msgs_lock.release()
            else:
                # pass it on
                for conn in connections.copy():
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                        
                    # send message
                    conn.connectionSend(msg)
                    
                    unack_msgs_lock.acquire()
                    unack_msgs[(conn, msg_num, msg)] = 0
                    unack_msgs_lock.release()
                
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # could be for us, we should check
        elif (msg_type == "reset"):
            if (name == msg_node):
                print("it's for us")
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
                for conn in connections.copy():
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                    
                    # send message
                    conn.connectionSend(msg)
                    
                    unack_msgs_lock.acquire()
                    unack_msgs[(conn, msg_num, msg)] = 0
                    unack_msgs_lock.release()
                    
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
            for conn in connections.copy():
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                conn.connectionSend(msg)
                
                unack_msgs_lock.acquire()
                unack_msgs[(conn, msg_num, msg)] = 0
                unack_msgs_lock.release()
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # just an ack, we don't need to respond with anything
        elif (msg_type == "ack"):
            print("handling ack")
            # find the message in the unacknowledged messages 
            unack_msgs_lock.acquire()
            for tup in unack_msgs.copy():
                print(tup[0].name + " " + connect.name + " " + str(tup[1]) + " " + msg_num)
                if (tup[0].name == connect.name) and (str(tup[1]) == msg_num):
                    print("removing ack from unack_msgs")
                    # message found, remove from dictionary
                    try:
                        unack_msgs.pop(tup)
                    except KeyError as e:
                        print(e)
                        print("unack message already removed")
                    break
            unack_msgs_lock.release()
            
        # could be for us, we should check
        elif (msg_type == "do indicate"):
            print("handling do indicate")
            
            if (name == msg_node):
                print("it's for us")
                # it's for you
                if not indicating:
                    indicator.indicatorStart(False)
                    indicating = True
                
            else:
                # pass it on
                for conn in connections.copy():
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                    
                    # send message
                    conn.connectionSend(msg)
                    
                    unack_msgs_lock.acquire()
                    unack_msgs[(conn, msg_num, msg)] = 0
                    unack_msgs_lock.release()
                    
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # is for us and everyone else
        elif (msg_type == "phone connect"):
            print("handling phone connect")
            
            # we are no longer responsible for connecting to the phone
            do_phone_discover = False
            
            #  pass message on 
            for conn in connections.copy():
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                conn.connectionSend(msg)
                
                unack_msgs_lock.acquire()
                unack_msgs[(conn, msg_num, msg)] = 0
                unack_msgs_lock.release()
            
            msg_id = messages.craftMessage("id", name)
            msg_id_num = int.from_bytes(msg_id[4:], "big")
            
            message_queue_lock.acquire()
            if len(message_queue) == MSG_Q_LEN:
                message_queue.pop(0)
            message_queue.append(msg_id_num)
            message_queue_lock.release()
            
            # send ID message to everyone, eventually the phone
            for conn in connections.copy():
                conn.connectionSend(msg_id)
                unack_msgs_lock.acquire()
                unack_msgs[(conn, msg_id_num, msg_id)] = 0
                unack_msgs_lock.release()
            
            if indicating:
                # create the indication message
                msg_indicating = messages.craftMessage("indicating", name)
                msg_num_indicating = int.from_bytes(msg_indicating[4:], "big")
                
                message_queue_lock.acquire()
                if len(message_queue) == MSG_Q_LEN:
                    message_queue.pop(0)
                message_queue.append(msg_num_indicating)
                message_queue_lock.release()
                
                if phone_connection:
                    phone_connection.connectionSend(msg_indicating)
                    
                    unack_msgs_lock.acquire()
                    unack_msgs[(phone_connection, msg_num_indicating, msg_indicating)] = 0
                    unack_msgs_lock.release()
                else:
                    # tell the whole world
                    for connect in connections.copy():
                        connect.connectionSend(msg_indicating)
                        unack_msgs_lock.acquire()
                        unack_msgs[(connect, msg_num_indicating, msg_indicating)] = 0
                        unack_msgs_lock.release()
                    
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        # is for us and everyone else    
        elif (msg_type == "phone lost"):
            print("handling phone lost")
            
            # we are potentially responsible for connecting to the phone
            do_phone_discover = True
            
            # we need to start a phone listener thread and try to connect
            phone_listener_thread = threading.Thread(target=phoneListenerThread, args=(unack_msgs_lock,))
            phone_listener_thread.start()
            
            #  pass message on 
            for conn in connections.copy():
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                conn.connectionSend(msg)
                
                unack_msgs_lock.acquire()
                unack_msgs[(conn, msg_num, msg)] = 0
                unack_msgs_lock.release()
            
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        elif (msg_type == "disconnect"):
            # check if we are to disconnect
            if (name == msg_node):
                # it's for you
                if indicating:
                    indicator.indicatorStop()
                os.system("shutdown -h now")
            
            else:
                # pass it on
                for conn in connections.copy():
                    # do not send message back to whomst've sent it 
                    if conn == connect:
                        continue
                    
                    # send message
                    conn.connectionSend(msg)
                    
                    unack_msgs_lock.acquire()
                    unack_msgs[(conn, msg_num, msg)] = 0
                    unack_msgs_lock.release()
                    
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
        elif (msg_type == "disconnect all"):
            # if we are indicating, stop
            if indicating:
                indicator.indicatorStop()
        
            # pass it on
            for conn in connections.copy():
                # do not send message back to whomst've sent it 
                if conn == connect:
                    continue
                
                # send message
                conn.connectionSend(msg)
                
                unack_msgs_lock.acquire()
                unack_msgs[(conn, msg_num, msg)] = 0
                unack_msgs_lock.release()
                
            # send ack
            msg_ack = messages.craftMessage("ack", name, msg_num)
            connect.connectionSend(msg_ack)
            
            # schedule shutdown
            os.system('bash -c "sleep 10; shutdown -h now" &')
            
            print("did this get read?")
            
        else:
            # error
            print("error, could not understand msg_type")
            continue
            
        print("end of message thread loop")
        
    print("end of message thread")

'''
phoneListenerThread

Listens for and connects to the mobile phone. This will run continuously for all nodes, except the
node that is maintaining the phone connection. 

Returns:
    None
Arguments:
    threading.Lock() connections_lock : lock acquired when accessing the connections list
    threading.Lock() reset_lock : lock acquired when accessing the reset flag
    threading.Lock() unack_msgs_lock : lock acquired when accessing the unacknowledged message dictionary
    threading.Lock() message_queue_lock : lock acquired when accessing the messages_queue
'''
def phoneListenerThread(connections_lock,reset_lock,unack_msgs_lock,message_queue_lock):

    global do_phone_discover
    global phone_connection
    global name
    global connections
    global phone_server_sock
    global phone_client_sock

    print("phone listener thread start")
    
    # define phone connection variables
    phone_server_port = 0
    phone_server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    phone_server_sock.bind(("", phone_server_port))
    #phone_server_sock.settimeout(10)
    phone_server_sock.setblocking(1)
    phone_server_sock.listen(1)
    
    #advertise service
    bluetooth.advertise_service(phone_server_sock, "Bluetooth Serial Port",
                                service_classes = [ bluetooth.SERIAL_PORT_CLASS ],
                                profiles = [ bluetooth.SERIAL_PORT_PROFILE ])
    
    
    phone_client_sock, info = phone_server_sock.accept()
    print("accepted phone connection; " + str(info[0]))
    phone_addr = info[0]
    #phone_client_sock.settimeout(10)
    #phone_client_sock.setblocking(0)
    

    while True:
        try:
            msg = phone_client_sock.recv(8)
            msg_type, msg_node, msg_num, __ = messages.parseMessage(msg)
            #if (msg_num != num_exp):
            #    print("number not correct")
            print("received [%s]" % msg)
            print(msg_node)
            break
        except Exception as e:
            print(e)
            #print("oh, I know")
            continue

    msg_connection = messages.craftMessage("connection", name, num=msg_num)

    while True:
        try:
            phone_client_sock.sendall(msg_connection)
            break
        except Exception as e:
            #print("ya know")
            continue
    
    # initialize phone connection object
    phone_connection = connection.Connection(phone_client_sock, phone_client_sock, phone_addr, phone_server_port, "PHONE")
    
    # start phone messages thread
    phone_thread = threading.Thread(target=message_thread, args=(phone_connection,connections_lock,reset_lock,unack_msgs_lock,message_queue_lock,name,))
    phone_thread.start()
    
    # craft phone found message
    msg_phone_connect = messages.craftMessage("phone connect", name)
    msg_num = int.from_bytes(msg_phone_connect[4:], "big")
    
    message_queue_lock.acquire()
    if len(message_queue) == MSG_Q_LEN:
        message_queue.pop(0)
    message_queue.append(msg_num)
    message_queue_lock.release()
    
    # tell the whole world that we are connected to the phone
    for conn in connections.copy():
        conn.connectionSend(msg_phone_connect)
        unack_msgs_lock.acquire()
        unack_msgs[(conn, msg_num, msg_phone_connect)] = 0
        unack_msgs_lock.release()
    
    do_phone_discover = False
    
    phone_server_sock.setblocking(1)
    phone_client_sock.setblocking(1)
    
    print("closing phone listener thread")


if __name__ == "__main__":
    main()



