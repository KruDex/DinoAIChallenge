class Dirt {

  PVector pos;
  Dirt(int x, int y) {
    pos = new PVector(x,y);
  }

  void update() {
    pos.x = pos.x - speed;
  }

  void show () {
    stroke(10);
    strokeWeight(2);
    point(pos.x, pos.y);
  }
};
