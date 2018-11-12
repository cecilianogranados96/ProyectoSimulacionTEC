class Food{
  PVector pos;
  color c;
  int mass, life;
  boolean dead;
  int timer;

  Food(float x, float y) {
    pos  = new PVector(x, y);
    mass = 2;
    c = color(135, 206, 255);
    dead = false;
    timer = int(random(0, 50));
  }

  void draw() {
    noStroke();
    ellipse(pos.x, pos.y, mass*5, mass*5);
  }
  
  PVector getPos() {
    return pos;
  }
  
  boolean isDead() {
    return dead;
  }
}
