class Pterodactylus {

  PVector pos;
  PVector size;
  int vel;
  PImage []sprites;
  PImage pteroFrame;
  boolean wingsUp = true;

  Pterodactylus() {
    pos = new PVector(width, random(20, horizonY-40));
    size = new PVector(35, 38);
    vel = speed + 2;
    sprites = new PImage[2];
    for (int i = 0; i < sprites.length; i++) {
      sprites[i] = pteroSprites.get(64 * i, 0, 64, 64);
    }
    pteroFrame = sprites[0];
  }

  void update() {
    pos.x = pos.x - vel;
  }

  void show() {
    pushMatrix();
    if (showDebugInfo) {
      stroke(200, 0, 0);
      noFill();
      rectMode(CENTER);
      rect(pos.x, pos.y, size.x, size.y);
    }
    imageMode(CENTER);
    if (frameCount%8==0) {
      if (wingsUp==true) {
        pteroFrame = sprites[0];
      } else {
        pteroFrame = sprites[1];
      }
      wingsUp =!wingsUp;
    }
    image(pteroFrame, pos.x, pos.y);
    popMatrix();
  }
};
