'''
This file defines message types and provides a function for parsing messages

Message format 
    byte 1      = flags, see below
    bytes 2 - 4 = node number (i.e., in dronecone123, the 123)
    bytes 5 - 8 = message number (random)
'''

import os

# message types
RESET = 0x0
INDICATE = 0x1
NEW_NODE = 0x2
NODE_LOST = 0x3
RESET_ALL = 0x4
ACK = 0x5

'''
parseMessage

Parses a message and returns a tuple with the type, node, and number

Returns:
    tuple(string, string, string) parsed_msg : tuple with type, node, and number
Arguments:
    bytes msg : the received message, in bytes
'''
def parseMessage(msg):
        
    msg_type = msg[0]
    if (msg_type == RESET):
        parsed_msg0 = "reset"
    elif (msg_type == INDICATE):
        parsed_msg0 = "indicate"
    elif (msg_type == NEW_NODE):
        parsed_msg0 = "new node"
    elif (msg_type == NODE_LOST):
        parsed_msg0 = "node lost"
    elif (msg_type == RESET_ALL):
        parsed_msg0 = "reset all"
    elif (msg_type == ACK):
        parsed_msg0 = "ack"
    
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
    string msg_type : "reset", "indicate", "new node", "node lost", or "reset all"
    string name : hostname of the node ("dronecone" and a number)
'''
def craftMessage(msg_type, name, num=None, name2=None):
    
    msg_int = 0
    
    # set first byte with message type
    if (msg_type == "reset"):
        msg_int = msg_int | (RESET << 56)
    elif (msg_type == "indicate"):
        msg_int = msg_int | (INDICATE << 56)
    elif (msg_type == "new node"):
        msg_int = msg_int | (NEW_NODE << 56)
    elif (msg_type == "node lost"):
        msg_int = msg_int | (NODE_LOST << 56)
    elif (msg_type == "reset all"):
        msg_int = msg_int | (RESET_ALL << 56)
    elif (msg_type == "ack"):
        msg_int = msg_int | (ACK << 56)
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
    