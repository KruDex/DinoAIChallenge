# DinoAIChallenge

This is an AI challenge based on a clone of the game when the Chromium Browser detects that you are offline... Anther clone of that game is [here](https://chromedino.com). The challenge or opportunity is to develop/train an AI that can play this game.

The game in this repository exposes an interface to the in game data via a UDP connection with JSON messages

## The Idea and other inspirations

For learning the basics of AI a lot of old games have been rewritten with interfaces to be ready to be experimented with. For example in the [OpenAI Gym](https://gym.openai.com) 

However there is a very tight coupling between the game, especialy the simulation step, and the AI algorithms. I want to try to (forecefully) decouple it. The game will run in normal speed and transmit the information via a UDP connection and will receive the commands also via this connections. The goal is thus to have a forced "real-time" training and gameplay to be a little bit closer to the reality e.g. robotics, where a simulation might not be available and the real physical process to be learned can not be stopped or waited for.

A similar attempt especially with this game was made and is available on [youtube](https://www.youtube.com/watch?v=sB_IGstiWlc) - the code is also here on [github] (https://github.com/Code-Bullet/Google-Chrome-Dino-Game-AI) Also here the AI and game are also coupled in Proccessing.

## The clone of the Dino Game

### The pure game

The clone of the game is written in Processing and is in the Folder [DinoAIProcessing](./DinoAIProcessing). The game if fully playable.

| Key        | Action               |
| ---------- |--------------        |
| space      | jump                 |
| down arrow | duck                 |
| r          | restart              |
| i          | toggle score display |
| d          | toggle debug view    |

It can be loaded in processing or in the latestes release [here](https://github.com/kruegerrobotics/DinoAIChallenge/releases/tag/v0.9)

### The UDP interface

The game listens for a udp message in a certain format on port 25001. Once a connection is made the game will respond on this connection and send its data with each frame. A python example is in this repository

#### Inital trigger message

To trigger the program to send out UDP message it needs to be triggered. This can be done by sending anything to port **25001** on the machine where the dino game is running

#### Message format for receving data from the game

Once the game is triggered by the initial message it will respond with this *telemetry*.

```json
{   "level" : 1,
    "height_obstacle" : 0,
    "instances" : 3,
    "distance_obstacle" : 127,
    "gameover": False,
    "dinos" : [{"id": 0, "score": 13, "player_height": 110}, {"id": 1, "score": 13, "player_height": 57.20000076293945}, {"id": 2, "score": 13, "player_height": 97}]}
```

##### The fields in the JSON message

| Field             | Meaning                                                                       |
| ----------        |--------------                                                                 |
| level             | The current level                                                             |
| height_obstacle   | The height of the next obstacle (the graphics y-coodinate 0 top - 150 high)   |
| instances         | The number of independent/simultaneous dinos in the game                      |
| distance_obstacle | The distance to the next obstacle                                             |
| dinos             | The array of all dino instances with specific information                     |

###### The specific dino message

| Field         | Meaning                                                   |
| ----------    |--------------                                             |
| id            | The id of the dino instance                               |
| score         | The score of this dino (will remain constant if dino dies)|
| player_height | The heigth of the dino (important when jumping)           |
| alive         | True if the dino is still alive                           |

#### Message format for sending to the game

A valid message sent to the game contains two mandatory fields: *command* and *num_instances* command The *command* can be left empty and the *num_instances* determine how many dinos will be in the game simultaneously (max. 20).

```json
    msg = {
        "command" : " ",
        "num_instances" : 3
    }
```

If the command is left empty the game will continue normally. The *num_instances* describes how many controllable dinos will be in the game simultaneously. Those dinos are totally independed from each other. The idea behind is to ease the training of heuristic or genetic algorithms and to test the differet mutations at the same time. The message as displayed is essential and if the *num_instances* is changed the **game will restart**.

| Command    | Description                      |
| ---------- |--------------                    |
| restart    | will issue the game to restart   |                 |

##### Commanding the dino

To command the instance of the dino the message has to contain an array called *dinos* with an objecy containing the fields *action* and *dino_instance*. The *dino_instances* addresses the dino and the *action* can be one of the following:

| Action    | Description                      |
| ----------|--------------                    |
| smalljump | the dino will do a small jump    |  
| bigjump   | the dino will do a big jump      |  
| duck      | the dino will duck               |  

##### Example for a big jump

```json
{
    "command" : " ",
    "num_instances" : 3
    "dinos" : [{"action" : "bigjump", "dino_instance" : 0}]
}
```

## Interface Example

In the [example](./example) is a python program to use the socket to communicate with the game and 

## TODO

- Scale of the obstacles
- Tuning of the obstacle distance so that the smalljump is required
- messages the distance between the obstacles
