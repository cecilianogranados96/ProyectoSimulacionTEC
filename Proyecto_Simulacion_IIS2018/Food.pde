class Food{
  PVector pos;  
  int mass, life;
  boolean dead;
  PImage img;
  
  Food(float x, float y, String type) {
    pos  = new PVector(x, y);
    mass = 2;    
    dead = false;
    setImage(type);
  }

  // Displays the food on the screen.
  void draw() {       
    pushMatrix();
    translate(pos.x, pos.y);
    image(img, 0, 0, img.width, img.height);
    popMatrix();
  }
  
  // Gets the position of the food.
  PVector getPos() {
    return pos;
  }
  
  // Checks if the food is already eaten.
  boolean isDead() {
    return dead;
  }
  
  // Loads an image based on its type (food or water).
  void setImage(String type){
    if(type.equals("food")){
      img = loadImage("food.png"); 
      img.resize(40, 40);
    }
    else{
      img = loadImage("water.png"); 
      img.resize(60, 60);
    }
  }
}
