
import socket
import json

def main():
    s = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    dest = ("127.0.0.1", 25001)
    #send the first message to trigger response and set 3 controllable dinos
    print ("Setting the program to 2 dino instancse")
    msg = {
        "command" : "",
        "num_instances" : 3
    }
    s.sendto(bytes(json.dumps(msg), "utf-8" ), dest)
    while True:
        #simple receive, process, send
        rawdata = s.recv(1024)
        data = json.loads(rawdata.decode('utf-8'))
        print(data)
        
        if data["gameover"] == True:
             #if the game is over (all dinos dead) restart
             msg = {
                "command" : "restart",
                "num_instances" : 3
            }
        else:
            #compose the message for each dino instance in the dinos array
            dino0 = {"action" : "duck",
                "dino_instance" : 0}
            
            dino1= {"action" : "bigjump",
                "dino_instance" : 1}

            dino2= {"action" : "smalljump",
                "dino_instance" : 2}
            msg = {
                "command" : " ",
                "num_instances" : 3,
                "dinos" : [dino0, dino1, dino2]
            }
        s.sendto(bytes(json.dumps(msg), "utf-8"), dest)

if __name__ == "__main__":
    main()