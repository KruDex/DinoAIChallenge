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

#### Format of the inital trigger message

This message contains the two mandatory fields for the game to respond. The *command* can be left empty and the *num_instances* determine how many dinos will be in the game simultaneously (max. 20).

```json
    msg = {
        "command" : " ",
        "num_instances" : 3
    }
```

The command can be left empty which will made the game continue normally. The number of instances describe how many controllable and dinos will be in the game simultaneously. Those dinos are totally independed from each other. The idea behind is to ease the training of heuristic or geneteic algorithms and to test the differet mutations at the same time. The message as displayed is essential and if the *num_instances* is changed the **game will restart**.

| Command    | Action                           |
| ---------- |--------------                    |
| restart    | will issue the game to restart   |                 |

#### Example data received

Once the game is triggered by the initial message it will respond with this *telemetry*.
**OLD info NEEDS TO BE UPDATED**

```json
{   "level" : 1,
    "height_obstacle" : 0,
    "instances" : 3,
    "distance_obstacle" : 127,
    "gameover": False,
    "dinos" : [{"id": 0, "score": 13, "player_height": 110}, {"id": 1, "score": 13, "player_height": 57.20000076293945}, {"id": 2, "score": 13, "player_height": 97}]}
```

##### The fields in the JSON message

| Field             | Meaning                                                   |
| ----------        |--------------                                             |
| level             | The current level                                         |
| height_obstacle   | The height of the next obstacle                           |
| instances         | The number of independent/simultaneous dinos in the game  |
| distance_obstacle | The distance to the next obstacle                         |
| dinos             | The array of all dino instances with specific information |

###### The specific dino message

| Field         | Meaning                                                   |
| ----------    |--------------                                             |
| id            | The id of the dino instance                               |
| score         | The score of this dino (will remain constant if dino dies)|
| player_height | The heigth of the dino (important when jumping)           |
| alive         | True if the dino is still alive                           |

#### Sending Data

Via the same connection data can be sent to the game

```json
{
    "command" : " ",
    "dinos" : [{"action" : " ", "dino_instance" : 0}]
}
```

*Detailed explanatin will come soon*

## Interface Example

In the [example](./example) is a python program to use the socket to communicate with the game

## TODO

This is under development and a few more things to do before it can be used

- improve the documentation on the JSON messages
