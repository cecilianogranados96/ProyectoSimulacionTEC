class Food{
  PVector pos;  
  int mass, life;
  boolean empty;
  PImage img;
  int quantity;
  
  Food(float x, float y, String type) {
    pos  = new PVector(x, y);
    mass = 2;    
    empty = false;
    setImage(type);
    quantity = int(random(0, 20));
  }

  // Displays the food on the screen.
  void draw() {       
    pushMatrix();
    translate(pos.x, pos.y);
    imageMode(CENTER);
    image(img, 0, 0, img.width, img.height);
    imageMode(CORNER);
    popMatrix();
    textSize(35);
    //text(quantity, pos.x, pos.y);
  }
  
  // Gets the position of the food.
  PVector getPos() {
    return pos;
  }
  
  // Checks if the food is already eaten.
  boolean isEmpty() {
    return empty;
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
  
  void eating(Zebra z){
    quantity--;
    
    if(quantity <= 0){
      empty = true;
      z.hungryCounter=int(random(5, 20))*100;
    }
  }
}
