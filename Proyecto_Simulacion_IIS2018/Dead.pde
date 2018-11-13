class Dead {
  PVector pos;
  PVector vel;
  PImage img;
  
  Dead(float x, float y, PVector v) {
    pos = new PVector(x, y);
    vel = v;
    img = loadImage("dead.png");
    img.resize(30, 35);
  }
  
  void draw() {
    float ang = vel.heading();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(ang);
    imageMode(CENTER);
    image(img, 0, 0, img.width, img.height);
    imageMode(CORNER);
    popMatrix();
  }
}
