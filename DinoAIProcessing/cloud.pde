class Cloud {
  PVector pos;
  int vel;

  Cloud(int x) {

    pos = new PVector(x, random(10, 30));
    vel = int(random(1, 3));
  }

  void update() {
    pos.x = pos.x - vel;
  }

  void show() {
    pushMatrix();
    imageMode(CENTER);
    image(cloudSprite, pos.x, pos.y);
    popMatrix();
  }
};
