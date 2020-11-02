'''

This file defines the Connection class, which is used by the node to manage multiple
connections and send data to the phone. 

'''

class Connection:
 
    def __init__(self, recv_sock, send_sock, port, addr):
        self.recv_sock = recv_sock
        self.send_sock = send_sock
        self.addr = addr
        self.port = port
        self.thread = None
    
    def connectionClose(self):
        sock.close()
        
    def connectionSend(self, message, ack=False, reply_sock=None):
        self.sock.send(message)
        
        #TODO: acknowledgement handling, resending on fail
        '''
        if ack:
            if recv_sock is None:
                print("must provide reply_sock to receive acknowledgement")
            else:
                ack = recv_sock.recv(1024)
        '''