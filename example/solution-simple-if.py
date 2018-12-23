
import socket
import json

def main():
    s = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    dest = ("127.0.0.1", 25001)
    #send the first message to trigger response and set 1 controllable dinos since we want to do it with a simple if
    print ("Setting the program to 1 dino instancse")
    msg = {
        "command" : "",
        "num_instances" : 1
    }
    s.sendto(bytes(json.dumps(msg), "utf-8" ), dest)
    while True:
        #simple receive, process, send
        rawdata = s.recv(1024)
        data = json.loads(rawdata.decode('utf-8'))
        
        print(data)
        #distance = data[]

        if data["gameover"] == True:
            #if the game is over (all dinos dead) restart
            msg = {
                "command" : "restart",
                "num_instances" : 1
            }
            s.sendto(bytes(json.dumps(msg), "utf-8"), dest)
        else:
            #compose the message for each dino instance in the dinos array
            if (data["distance_obstacle"] <= 50):
                if data["height_obstacle"] > 120:
                    dino0 = {"action" : "bigjump",
                    "dino_instance" : 0}
                
                    msg = {
                    "command" : " ",
                    "num_instances" : 1,
                    "dinos" : [dino0]
                }
                else:
                    dino0 = {"action" : "duck",
                    "dino_instance" : 0}
                    msg = {
                        "command" : " ",
                        "num_instances" : 1,
                        "dinos" : [dino0]
                    }
                s.sendto(bytes(json.dumps(msg), "utf-8"), dest)

if __name__ == "__main__":
    main()