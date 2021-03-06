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
        self.send_sock.close()
        self.recv_sock.close()
        
    def connectionSend(self, message):
        print("sending message " + str(message))
        self.send_sock.sendall(message)
    