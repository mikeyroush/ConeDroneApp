'''

This file defines message types and provides a function for parsing messages

'''

import os

'''

Message format 
    byte 1      = flags, see below
    bytes 2 - 4 = node numbers (i.e., in dronecone123, the 123)
        bits 9 - 20 = other node number (used by new node and node lost, 0 for other types)
        bits 21 - 32 = node number (all messages)
    bytes 5 - 8 = message number (random)

'''

# message types
RESET = 0x0
INDICATING = 0x1
NEW_NODE = 0x2
NODE_LOST = 0x3
RESET_ALL = 0x4
ACK = 0x5
DO_INDICATE = 0x6
PHONE_CONNECT = 0x7
PHONE_LOST = 0x8
CONNECTION = 0x9
ID = 0xA
DISCONNECT = 0xB
DISCONNECT_ALL = 0xC

'''
parseMessage

Parses a message and returns a tuple with the type, node, and number

Returns:
    tuple(string, string, string, string) parsed_msg : tuple with type, node, number, and other node
Arguments:
    bytes msg : the received message, in bytes
'''
def parseMessage(msg):
        
    msg_type = msg[0]
    if (msg_type == RESET):
        parsed_msg0 = "reset"
    elif (msg_type == INDICATING):
        parsed_msg0 = "indicating"
    elif (msg_type == NEW_NODE):
        parsed_msg0 = "new node"
    elif (msg_type == NODE_LOST):
        parsed_msg0 = "node lost"
    elif (msg_type == RESET_ALL):
        parsed_msg0 = "reset all"
    elif (msg_type == ACK):
        parsed_msg0 = "ack"
    elif (msg_type == DO_INDICATE):
        parsed_msg0 = "do indicate"
    elif (msg_type == PHONE_CONNECT):
        parsed_msg0 = "phone connect"
    elif (msg_type == PHONE_LOST):
        parsed_msg0 = "phone lost"
    elif (msg_type == CONNECTION):
        parsed_msg0 = "connection"
    elif (msg_type == ID):
        parsed_msg0 = "id"
    elif (msg_type == DISCONNECT):
        parsed_msg0 = "disconnect"
    elif (msg_type == DISCONNECT_ALL):
        parsed_msg0 = "disconnect all"
    else:
        print("could not understand message type")
    
    # get the msg_node that is present for all messages
    msg_node_full = int.from_bytes(msg[1:4], "big")
    msg_node = (msg_node_full & 0x000FFF)
    parsed_msg1 = "dronecone" + str(msg_node)
    
    # get the message number
    msg_num = int.from_bytes(msg[4:], "big")
    parsed_msg2 = str(msg_num)
    
    # get the msg_node that is present for new node and node lost messages
    msg_node2 = (msg_node_full & 0xFFF000) >> 12
    parsed_msg3 = "dronecone" + str(msg_node2)
    
    # create return tuple
    parsed_msg = (parsed_msg0, parsed_msg1, parsed_msg2, parsed_msg3)
    
    return parsed_msg
    
    
'''
craftMessage

Forms a message given the message type and name 

Returns:
    bytes msg : the message to be sent, in bytes
Arguments:
    string msg_type : "reset", "indicating", "new node", "node lost", or "reset all"
    string name : hostname of the node ("dronecone" and a number)
    string num : message number (only passed in for acks)
    string name2 : hostname of the other node (only used for new node and node lost)
'''
def craftMessage(msg_type, name, num=None, name2=None):
    
    msg_int = 0
    
    # set first byte with message type
    if (msg_type == "reset"):
        msg_int = msg_int | (RESET << 56)
    elif (msg_type == "indicating"):
        msg_int = msg_int | (INDICATING << 56)
    elif (msg_type == "new node"):
        msg_int = msg_int | (NEW_NODE << 56)
    elif (msg_type == "node lost"):
        msg_int = msg_int | (NODE_LOST << 56)
    elif (msg_type == "reset all"):
        msg_int = msg_int | (RESET_ALL << 56)
    elif (msg_type == "ack"):
        msg_int = msg_int | (ACK << 56)
    elif (msg_type == "do indicate"):
        msg_int = msg_int | (DO_INDICATE << 56)
    elif (msg_type == "phone connect"):
        msg_int = msg_int | (PHONE_CONNECT << 56)
    elif (msg_type == "phone lost"):
        msg_int = msg_int | (PHONE_LOST << 56)
    elif (msg_type == "connection"):
        msg_int = msg_int | (CONNECTION << 56)
    elif (msg_type == "id"):
        msg_int = msg_int | (ID << 56)
    elif (msg_type == "disconnect"):
        msg_int = msg_int | (DISCONNECT << 56)
    elif (msg_type == "disconnect all"):
        msg_int = msg_int | (DISCONNECT_ALL << 56)
    else:
        print("Error: craftMessage cannot understand message type")
    
    # set new or lost node number
    if name2:
        # should only occur for new node or lost node messages
        msg_node2 = int(name2[9:])
        msg_int = msg_int | (msg_node2 << 44)
        
    
    # set bytes 2-4 with node number
    msg_node = int(name[9:])
    msg_int = msg_int | (msg_node << 32)
    
    # set final four bytes with random bytes, or given number 
    if num:
        # should only occur if ack message is requested
        msg_int = msg_int | int(num)
    else:
        msg_int = msg_int | (int.from_bytes(os.urandom(4), "big"))
    
    # convert message into bytes
    msg = msg_int.to_bytes(8, "big")
    
    return msg   
    
