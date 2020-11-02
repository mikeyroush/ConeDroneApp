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
    
    msg_type = (msg[0] && 0x00000111)
    if (msg_type == RESET):
        parsed_msg[0] = "reset"
    elif (msg_type == INDICATE):
        parsed_msg[0] = "indicate"
    elif (msg_type == NEW_NODE):
        parsed_msg[0] = "new node"
    elif (msg_type == NODE_LOST):
        parsed_msg[0] = "node lost"
    elif (msg_type == RESET_ALL):
        parsed_msg[0] = "reset all"
    
    msg_node = msg[1:3].decode()
    parsed_msg[1] = "dronecone" + msg_node
    
    msg_num = msg[5:]
    parsed_msg[2] = str(msg_num)
    
    return parsed_msg    