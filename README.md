# DinoAIChallenge

This is an AI challenge based on a clone of the game when the Chromium Browser detects that you are offline... An inspriation is [here](https://chromedino.com)

The game is similar but exposes an interface to the in game data via a TCP connection with JSON messages

## The Idea and other inspirations

For learning the basics of AI a lot of old games have been rewritten with interfaces to be ready to be experimented with. For example in the [OpenAI Gym](https://gym.openai.com) 

However there is a very tight coupling between the game, especialy the simulation step, and the AI algorithms. I want to try to (forecefully) decouple it. The game will run in normal speed and transmit the information via a TCP connection and will receive the commands also via this connections. The goal is thus to have a "real-time" training and gameplay to be a little bit closer to the reality where a simulation might not be available and the process to be learned can not be stopped or waited for.

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

It can be loaded in processing or in the latestes release here *coming soon*

### The TCP interface

The game runs a TCP server in listen mode on port 25001. Once a connection is made the game will send its data with each frame.

#### Example data received

```json
{   'score': 25,
    'gameover': False,
    'level': 1,
    'distance_obstacle': 235,
    'player_height': 52,
    'height_obstacle': 122,
    'status': 'running'
}
```

*Detailed explanatin will come soon*

#### Sending Data

Via the same connection data can be sent to the game

```json
{
    "command" : " ",
    "action" : " ",
    "dino_instance" : 0
}
```

*Detailed explanatin will come soon*

## Interface Example

In the [example](./example) is a python program to use the socket to communicate with the game