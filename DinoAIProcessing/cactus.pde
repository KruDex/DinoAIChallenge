class Cactus
{
  PVector pos;
  PVector size;
  int num;

  Cactus(int xpos) {
    pos = new PVector(xpos, 100);
    size = new PVector(34, 44);
    num = int(random(1,3));
  }

  void update() {
    pos.x = pos.x - speed;
  }

  void show() {
    pushMatrix();
    if (showDebugInfo) {
      noFill();
      stroke(200, 0, 0);
      rectMode(CENTER);
      rect(pos.x, pos.y, size.x, size.y);
    }
    imageMode(CENTER);
    image(cactusSprite, pos.x, pos.y);
    popMatrix();
  }
};
