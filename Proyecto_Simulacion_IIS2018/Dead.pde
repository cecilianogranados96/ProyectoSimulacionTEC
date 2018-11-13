class Dead {
  PVector pos;
  PImage img;
  
  Dead(float x, float y) {
    pos = new PVector(x, y);
    img = loadImage("dead.png");
    img.resize(30, 35);
  }
  
  void draw() {       
    pushMatrix();
    translate(pos.x, pos.y);
    imageMode(CENTER);
    image(img, 0, 0, img.width, img.height);
    imageMode(CORNER);
    popMatrix();
  }
}
