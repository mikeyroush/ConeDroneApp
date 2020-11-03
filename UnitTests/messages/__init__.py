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
    
    
    
    #msg_type = (msg[0] & 0x00000111)
    msg_type = msg[0]
    # print("msg_type",  msg_type)
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
    # print("parsed_msg0", parsed_msg0)
    msg_node = int.from_bytes(msg[1:4], "big")
    parsed_msg1 = "dronecone" + str(msg_node)
    
    msg_num = int.from_bytes(msg[4:], "big")
    parsed_msg2 = str(msg_num)

    parsed_msg = (parsed_msg0, parsed_msg1, parsed_msg2)
    
    return parsed_msg    

# expecting: ("reset", "dronecone385", "829483")
# msg1 = b'\x00\x00\x01\x81\x00\x0c\xa8\x2b'
# x = parseMessage(msg)
# print("x:", x)
# msg2 = b'\x04\x00\x28\x35\x00\x00\x00\x12'
# x2 = parseMessage(msg2)
# print("x:", x2)