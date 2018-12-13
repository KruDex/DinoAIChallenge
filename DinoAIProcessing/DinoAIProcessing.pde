import hypermedia.net.*; //<>// //<>// //<>//
import processing.sound.*;
// in case the sim takes many dinos
int dinoInstances = 1;
int maxDinoInstances = 20;

ArrayList<Dino> dinos = new ArrayList<Dino>();
ArrayList<Cactus> cactuses = new ArrayList<Cactus>();
ArrayList<Dirt> soil = new ArrayList<Dirt>();
ArrayList<Cloud> clouds = new ArrayList<Cloud>();
ArrayList<Pterodactylus> flyers = new ArrayList<Pterodactylus>();

int speed;
int cloudTimer;
int soilTimer;
int horizonY;
int numDinos;
int level;
int obstacleTimer;
int score;
int highScore;
float distanceObstacle;
float heightObstacle;
boolean isGameOver;

//in game options toggles
boolean hideScore;
boolean showDebugInfo;

//graphics
PImage cactusSprite;
PImage dinoSprites;
PImage cloudSprite;
PImage pteroSprites;

//sounds
SoundFile jumpSound;
SoundFile levelUpSound;
SoundFile hurtSound;

PFont pixelFont;

//for the network
UDP udpConn;
String partnerIP = "";
int   partnerPort = -1;
boolean connectionEstablished = false;

//data exchange JSONs
JSONObject gameData;
JSONArray dinoData;


String Version = "0.9.1";

void init()
{
  //simple "replacement" for the setup call, since setup should maybe be only called once in the processing flow
  //init some values also after restart
  horizonY = height - 40;
  level = 1;
  speed = 12;
  obstacleTimer = 50;
  soilTimer = 5;
  cloudTimer = 150;
  score = 0;
  isGameOver = false;
  showDebugInfo = false;
  //some initial dirt
  for (int i = 0; i<25; i++) {
    int x = int (random(width));
    int y = int (random(horizonY + 10, height - 10));
    soil.add(new Dirt(x, y));
  }

  //populating the dino array
  for (int i = 0; i<dinoInstances; i++) {
    dinos.add(new Dino());
  }

  dinoData = new JSONArray();
  frameRate(30);
  loop();
}

void setup () {
  size(600, 150);
  frameRate(30);

  //load the font
  pixelFont = createFont("04B_03__.TTF", 32);

  //load the sprites
  cactusSprite = loadImage("Cactus.png");
  dinoSprites = loadImage("Dino.png");
  cloudSprite = loadImage("cloud.png");
  pteroSprites = loadImage("pteros.png");

  //load the sounds
  jumpSound = new SoundFile(this, "Jump.wav");
  levelUpSound = new SoundFile(this, "Levelup.wav");
  hurtSound = new SoundFile(this, "Hurt.wav");

  //interface and com variables
  udpConn = new UDP(this, 25001);
  udpConn.listen(true);
  gameData = new JSONObject();
  hideScore = false;
  highScore = 0;
  init();
}

void receive( byte[] data, String ip, int port ) {
  partnerIP = ip;
  partnerPort = port;
  connectionEstablished = true;
  String message = new String( data );
  //interpreting the message
  // a bit problematic since any field that is not send will cause an exception, thus the client needs to send all
  try {
    JSONObject msg = parseJSONObject(message);
    JSONArray dinoMsgs = msg.getJSONArray("dinos");
    try {
      for (int i=0; i<dinoMsgs.size(); i++) {
        JSONObject dinoCmd = dinoMsgs.getJSONObject(i);
        int addressedDino = dinoCmd.getInt("dino_instance");
        addressedDino = constrain(addressedDino, 0, dinoInstances-1);

        if (dinoCmd.getString("action").equals("duck")) {
          dinos.get(addressedDino).isDucking = true;
        } else if (dinoCmd.getString("action").equals("bigjump")) {
          dinos.get(addressedDino).jump();
          dinos.get(addressedDino).setLowGrav();
        } else if (dinoCmd.getString("action").equals("smalljump")) {
          dinos.get(addressedDino).jump();
          dinos.get(addressedDino).setNormalGrav();
        }
      }
    }
    catch (Exception e) {
      println("Error reading JSON array for the dinos");
    }
    if (msg.getString("command").equals("restart")) {
      restart();
    }

    if (msg.getInt("num_instances") != dinoInstances) {
      dinoInstances = msg.getInt("num_instances");
      constrain(dinoInstances, 1, maxDinoInstances);
      println("Changed dino instance number to:", dinoInstances);
      dinoInstances = msg.getInt("num_instances");
      restart();
    }
  }
  catch (Exception e) {
    println("Error reading JSON from network");
  }
}

void draw() {
  //all the game logic if the game is running respective "not game over"
  if (!isGameOver) {
    background(220);
    stroke(10);
    strokeWeight(1);
    line(0, horizonY, width, horizonY);

    //paint the dirt
    for (Dirt d : soil) {
      d.update();
      d.show();
    }

    //paint the clouds
    for (Cloud c : clouds) {
      c.update();
      c.show();
    }

    //paint the pteros

    for (Pterodactylus p : flyers) {
      p.update();
      p.show();
      for (Dino dino : dinos) {
        if (p.pos.x - p.size.x/2 < dino.pos.x + dino.size.x/2 &&
          p.pos.x + p.size.x/2 > dino.pos.x - dino.size.x/2 &&
          p.pos.y - p.size.y/2 < dino.pos.y + dino.size.y/2 &&
          p.pos.y + p.size.y/2 > dino.pos.y - dino.size.y/2) {
          dino.die();
        }
      }
    }
    //paint the cactues and check for collision
    for (Cactus c : cactuses) {
      c.update();
      c.show();
      for (Dino dino : dinos) {
        //check for collisions
        if (c.pos.x - c.size.x/2 < dino.pos.x + dino.size.x/2 &&
          c.pos.x + c.size.x/2 > dino.pos.x - dino.size.x/2 &&
          c.pos.y -c.size.y/2 < dino.pos.y + dino.size.y/2) {
          dino.die();
        }
      }
    }

    //paint the dinos
    for (Dino dino : dinos) {
      //only update the dinos alive
      if (dino.alive) {
        dino.update();
        dino.show();
        dino.score = score;
      }
    }

    //check if all dinos are dead - then gameOver
    isGameOver = true;
    for (Dino dino : dinos) {
      if (dino.alive == true) {
        isGameOver = false;
        break;
      } else {
        isGameOver = true;
      }
    }
    //check if insert a new obstactle
    if (obstacleTimer <= 0) {
      if (level < 3) {
        //it will be a cactus
        cactuses.add(new Cactus(width));
      } else {
        //it will be a ptero or a cactus
        int kind = int(random(10));
        if (kind >=7) {
          flyers.add(new Pterodactylus());
        } else {
          cactuses.add(new Cactus(width));
        }
      }
      obstacleTimer = 20 + int(random(30));
    }
    obstacleTimer--;

    //check to insert new soil
    if (soilTimer <= 0) {
      int y = int (random(horizonY + 10, height -10));
      soil.add(new Dirt(width, y ));
      soilTimer = 5 + int(random(5));
    }
    soilTimer--;

    //check to insert new cloud
    if (cloudTimer <= 0) {
      clouds.add(new Cloud(width));
      cloudTimer = 100 + int(random(100));
    }
    cloudTimer--;

    //remove stuff if offscreen
    for (int i=cactuses.size()-1; i >=0; i--)
    {
      Cactus c = cactuses.get(i);
      if (c.pos.x < - 20) {
        cactuses.remove(i);
      }
    }

    for (int i=soil.size()-1; i >=0; i--)
    {
      Dirt d = soil.get(i);
      if (d.pos.x < - 20) {
        soil.remove(i);
      }
    }

    for (int i=clouds.size()-1; i >=0; i--)
    {
      Cloud c = clouds.get(i);
      if (c.pos.x < - 20) {
        clouds.remove(i);
      }
    }

    for (int i=flyers.size()-1; i >=0; i--)
    {
      Pterodactylus f = flyers.get(i);
      if (f.pos.x < - 20) {
        flyers.remove(i);
      }
    }
    //gamelogic
    if (frameCount % 3 == 0 && !isGameOver) {
      score++;
    }

    if (score > level * 150)
    {
      level++;
      frameRate(30 + level);
      levelUpSound.play();
    }
  }//if (!isGameOver)
  //display the score
  if (hideScore == false) {
    pushMatrix();
    textFont(pixelFont);
    textSize(20);
    textAlign(RIGHT, TOP);
    fill(0);
    text(score, width - 50, 10);
    fill(80);
    text(highScore, width - 100, 10);
    text("lvl:" + level, width - 150, 10);

    popMatrix();
  } 

  //items to present to the outside world the AI
  //calculate the closest obstacle
  if (flyers.size() == 0 && cactuses.size() == 0)
  {
    distanceObstacle = 9999;
    heightObstacle = 0;
  } else {
    float distFlyer = 999;
    float distCactus = 999;

    Pterodactylus tempPtero = new Pterodactylus();
    Cactus tempCactus = new Cactus(width);
    for (Pterodactylus f : flyers) {
      float distance = f.pos.x -  f.size.x/2 - dinos.get(0).pos.x + dinos.get(0).size.x/2;
      if (distance > 0)
      {
        distFlyer = distance;
        tempPtero = f;
        break;
      }
    }
    for (Cactus c : cactuses) {
      float distance = (c.pos.x -  c.size.x/2) - (dinos.get(0).pos.x + dinos.get(0).size.x/2);
      if (distance > 0)
      {
        //just a line to visualize the distance
        if (showDebugInfo) {
          stroke(10);
          line(dinos.get(0).pos.x + dinos.get(0).size.x/2, 10, c.pos.x -  c.size.x/2, 10);
        }
        distCactus = distance;
        tempCactus = c;
        break;
      }
    }
    if (distFlyer < distCactus) {
      distanceObstacle = distFlyer;
      heightObstacle = tempPtero.pos.y + tempPtero.size.y/2;
    } else {
      distanceObstacle = distCactus;
      heightObstacle = tempCactus.pos.y + tempCactus.size.y/2;
    }
  }

  if (showDebugInfo) {
    fill(80);
    textFont(pixelFont);
    textSize(20);
    textAlign(LEFT, TOP);
    text(Version, 10, 10);
  }
  //write to the network
  gameData.setInt("level", level);
  gameData.setFloat("distance_obstacle", distanceObstacle);
  gameData.setFloat("height_obstacle", heightObstacle);
  gameData.setBoolean("gameover", isGameOver);
  for (int i=0; i<dinos.size(); i++) {
    JSONObject dinoField = new JSONObject();
    dinoField.setInt("id", i);
    dinoField.setFloat("player_height", dinos.get(i).pos.y);
    dinoField.setInt("score", dinos.get(i).score);
    dinoField.setBoolean("alive", dinos.get(i).alive);
    dinoData.setJSONObject(i, dinoField);
  }
  gameData.setJSONArray("dinos", dinoData);

  gameData.setInt("instances", dinoInstances);
  if (connectionEstablished) {
    udpConn.send(gameData.toString(), partnerIP, partnerPort );
  }
  //interfaceServer.write(gameData.toString());
  /*
  Client thisClient = interfaceServer.available();
   // If the client is not null, and says something, display what it said
   if (thisClient !=null) {
   String clientMsg = thisClient.readString();
   if (clientMsg != null) {
   // a bit problematic since any field that is not send will cause an exception, thus the client needs to send all
   JSONObject msg = parseJSONObject(clientMsg);
   JSONArray dinoMsgs = msg.getJSONArray("dinos");
   
   try {
   for (int i=0; i<dinoMsgs.size(); i++) {
   println(dinoMsgs.get(i));
   int addressedDino = msg.getInt("dino_instance");
   addressedDino = constrain(addressedDino, 0, dinoInstances);
   
   if (msg.getString("action").equals("duck")) {
   dinos.get(addressedDino).isDucking = true;
   } else if (msg.getString("action").equals("bigjump")) {
   dinos.get(addressedDino).jump();
   dinos.get(addressedDino).setLowGrav();
   println("Jump");
   } else if (msg.getString("action").equals("smalljump")) {
   dinos.get(addressedDino).jump();
   dinos.get(addressedDino).setNormalGrav();
   }
   }
   }
   catch (Exception e) {
   println("Error reading JSON array for the dinos");
   }
   
   if (msg.getString("command").equals("restart")) {
   restart();
   }
   
   if (msg.getInt("num_instances") != dinoInstances) {
   dinoInstances = msg.getInt("num_instances");
   constrain(dinoInstances, 1, maxDinoInstances);
   println("Changed dino instance number to:", dinoInstances);
   dinoInstances = msg.getInt("num_instances");
   restart();
   }
   }
   }*/
  if (isGameOver)
  {
    gameOver();
  }
}

void restart() {
  soil.clear();
  cactuses.clear();
  flyers.clear();
  dinos.clear();
  if (score > highScore) {
    highScore = score;
  }
  init();
}

void keyPressed() {
  //the keyboard always controls the first dino with the 0 zero
  switch (key) {
  case ' ':
    dinos.get(0).jump();
    dinos.get(0).setLowGrav();
    break;
  case 'r':
    restart();
    break;
  case 'i':
    hideScore = !hideScore;
    break;
  case 'd':
    showDebugInfo = !showDebugInfo;
    break;
  }

  switch (keyCode) {
  case DOWN:
    dinos.get(0).isDucking = true;
    break;
  }
}

void keyReleased() {
  switch (key) {
  case ' ':
    if (dinos.get(0).jumpTimer < 15) {
      dinos.get(0).setNormalGrav();
    }
    break;
  }

  switch (keyCode) {
  case DOWN:
    dinos.get(0).isDucking = false;
    break;
  }
}

void gameOver() {
  pushMatrix();
  textSize(32);
  textFont(pixelFont);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Game Over!", width/2, height/2-50);
  textSize(16);
  text("Press R to Restart", width/2, height/2 - 25);
  popMatrix();
}
