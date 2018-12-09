import processing.net.*; //<>//

Dino dino;
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



PImage cactusSprite;
PImage dinoSprites;
PImage cloudSprite;
PImage pteroSprites;

PFont pixelFont;

//for the network
Server interfaceServer;
JSONObject gameData;

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
  dino = new Dino();
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

  //interface and com variables
  interfaceServer = new Server(this, 25001);
  gameData = new JSONObject();
  hideScore = false;
  highScore = 0;
  init();
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

    //paint the dino
    dino.update();
    dino.show();

    //paint the pteros
    for (Pterodactylus p : flyers) {
      p.update();
      p.show();

      if (p.pos.x - p.size.x/2 < dino.pos.x + dino.size.x/2 &&
        p.pos.x + p.size.x/2 > dino.pos.x - dino.size.x/2 &&
        p.pos.y - p.size.y/2 < dino.pos.y + dino.size.y/2 &&
        p.pos.y + p.size.y/2 > dino.pos.y - dino.size.y/2) {
        isGameOver = true;
      }
    }

    //paint the cactues and check for collision
    for (Cactus c : cactuses) {
      c.update();
      c.show();
      //check for collisions
      if (c.pos.x - c.size.x/2 < dino.pos.x + dino.size.x/2 &&
        c.pos.x + c.size.x/2 > dino.pos.x - dino.size.x/2 &&
        c.pos.y -c.size.y/2 < dino.pos.y + dino.size.y/2) {
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

    fill(80);
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
      float distance = f.pos.x -  f.size.x/2 - dino.pos.x + dino.size.x/2;
      if (distance > 0)
      {
        distFlyer = distance;
        tempPtero = f;
        break;
      }
    }
    for (Cactus c : cactuses) {
      float distance = (c.pos.x -  c.size.x/2) - (dino.pos.x + dino.size.x/2);
      if (distance > 0)
      {
        //just a line to visualize the distance
        if (showDebugInfo) {
          stroke(10);
          line(dino.pos.x + dino.size.x/2, 10, c.pos.x -  c.size.x/2, 10);
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

  //write to the network
  gameData.setInt("score", score);
  gameData.setString("status", "running");
  gameData.setInt("level", level);
  gameData.setFloat("distance_obstacle", distanceObstacle);
  gameData.setFloat("height_obstacle", heightObstacle);
  gameData.setBoolean("gameover", isGameOver);
  gameData.setFloat("player_height", dino.pos.y);
  interfaceServer.write(gameData.toString());
  Client thisClient = interfaceServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String clientMsg = thisClient.readString();
    if (clientMsg != null) {
      JSONObject msg = parseJSONObject(clientMsg);
      if (msg.getString("command").equals("restart")) {
        restart(); //<>//
      }
      if (msg.getString("action").equals("duck")) {
        dino.isDucking = true;
      }
      if (msg.getString("action").equals("bigjump")) {
        dino.jump();
        dino.setLowGrav();
        println("Jump");
      }
      if (msg.getString("action").equals("smalljump")) {
        dino.jump();
        dino.setNormalGrav();
      }
    }
  }
  if (isGameOver)
  {
    gameOver();
  }
}

void restart() {
  soil.clear();
  cactuses.clear();
  flyers.clear();
  if (score > highScore) {
    highScore = score;
  }
  init();
}

void keyPressed() {
  switch (key) {
  case ' ':
    dino.jump();
    dino.setLowGrav();
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
    dino.isDucking = true;
    break;
  }
}

void keyReleased() {
  switch (key) {
  case ' ':
    if (dino.jumpTimer < 15) {
      dino.setNormalGrav();
    }
    break;
  }

  switch (keyCode) {
  case DOWN:
    dino.isDucking = false;
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
