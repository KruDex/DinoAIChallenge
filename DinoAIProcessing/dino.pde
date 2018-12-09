class Dino {
  PVector pos;
  PVector size;
  PVector sizeRunning;
  PVector sizeJumping;
  PVector sizeDucking;
  float accY = 0;
  float velY = 0;
  float forceY = 0;
  float gravity = 0.8;
  int jumpTimer = 0;

  float initialY = 110;
  boolean leftFoot = true;
  PImage []sprites;
  PImage dinoFrame;
  boolean isDucking = false;


  Dino() {
    pos = new PVector(40, initialY);
    sizeRunning =  new PVector(40, 48);
    sizeJumping = new PVector(40, 38);
    sizeDucking = new PVector(45, 32);
    size = sizeRunning;

    sprites = new PImage[5];
    for (int i = 0; i < sprites.length; i++) {
      sprites[i] = dinoSprites.get(64 * i, 0, 64, 64);
    }
    dinoFrame = sprites[0];
    setLowGrav();
  }

  void jump() {
    if (pos.y == initialY)
    {
      forceY = -22;//force;
    }
  }

  void setLowGrav() {
    gravity = 2.2;
  }

  void setNormalGrav() {
    gravity = 3.0;
  }

  void update() {
    //euler solver for the gravity
    forceY = forceY + gravity;
    accY = forceY;
    velY = velY + accY; 
    pos.y = pos.y + velY;


    pos.y = constrain(pos.y, -200, initialY);
    if (pos.y >= initialY)
    {
      velY = 0;
      jumpTimer = 0;
    } else {
      jumpTimer++;
    }

    //println("Force" + forceY, "Vel:", velY, " posy: ", pos.y, " initialY: ", initialY, "JT:", jumpTimer);
    //end of each time step forces and accelarations are nulled
    forceY = 0;
  }

  void show() {
    pushMatrix();
    if (showDebugInfo) {
      fill(0, 0);
      stroke(200, 0, 0);
      rectMode(CENTER);
      rect(pos.x, pos.y, size.x, size.y);
    }
    imageMode(CENTER);

    if (pos.y < initialY) {
      //we are jumping
      dinoFrame = sprites[2];
      size = sizeJumping;
    } else {
      //we are running or ducking
      if (frameCount%3==0) {
        if (leftFoot==true) {
          if (isDucking == true) {
            size = sizeDucking;
            dinoFrame = sprites[3];
          } else {
            size = sizeRunning;
            dinoFrame = sprites[0];
          }
        } else {
          if (isDucking == true) {
            size = sizeDucking;
            dinoFrame = sprites[4];
          } else {
            size = sizeRunning;
            dinoFrame = sprites[1];
          }
        }
      } 
      leftFoot = !leftFoot;
    }
    image(dinoFrame, pos.x, pos.y);
    popMatrix();
  }
};
