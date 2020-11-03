import time
import random

'''
This file defines message types and provides a function for parsing messages

Message format 
    byte 1      = flags, see below
    bytes 2 - 4 = node number (i.e., in dronecone123, the 123)
    bytes 5 - 8 = message number (random)
'''

RESET = 0x0
INDICATE = 0x1
NEW_NODE = 0x2
NODE_LOST = 0x3
RESET_ALL = 0x4

def parseMessage(msg):
    
    parsed_msg = ("", "", "")
    
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
    
    msg_node = int.from_bytes(msg[1:4], "big")
    parsed_msg1 = "dronecone" + str(msg_node)
    
    msg_num = int.from_bytes(msg[4:], "big")
    parsed_msg2 = str(msg_num)
    
    parsed_msg = (parsed_msg0, parsed_msg1, parsed_msg2)
    
    return parsed_msg
    
def craftMessage(msg_type, name):
    
    msg_int = 0
    
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
    else:
        print("Error: craftMessage cannot understand message type")
    
    msg_node = int(name[9:])
    msg_int = msg_int | (msg_node << 32)
    
    msg_int = msg_int | (int.from_bytes(random.randbytes(4), "big"))
    
    return msg_int.to_bytes(8, "big")
    
    
    
    
    
    
    
    