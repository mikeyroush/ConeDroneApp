'''

This file defines the Connection class, which is used by the node to manage multiple
connections and send data to the phone. 

'''

class Connection:
 
    def __init__(self, recv_sock, send_sock, addr, port, name):
        self.recv_sock = recv_sock
        self.send_sock = send_sock
        self.addr = addr
        self.port = port
        self.thread = None
        self.name = name
    
    def connectionClose(self):
        send_sock.close()
        recv_sock.close()
        
    def connectionSend(self, message):
        self.sock.sendall(message)
        
        #TODO: acknowledgement handling, resending on fail
        '''
        if ack:
            if recv_sock is None:
                print("must provide reply_sock to receive acknowledgement")
            else:
                ack = recv_sock.recv(1024)
        '''