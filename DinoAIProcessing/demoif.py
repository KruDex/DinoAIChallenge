
import socket
import json

def main():
    s = socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM)
    s.connect(("127.0.0.1", 25001))
    print ("Start")
    print 
    
    print("Com loop")
    while True:
        rawdata = s.recv(2048)
        data = json.loads(rawdata.decode('utf-8'))
        msg = {
            "command" : " ",
            "action" : " ",
            "dino_instance" : 0
        }
       
        if data["gameover"] == True:
            msg["command"] = "restart"
            s.send(bytes(json.dumps(msg), "utf-8"))

        msg["action"] = "smalljump"  
        s.send(bytes(json.dumps(msg), "utf-8"))

if __name__ == "__main__":
    main()