import controlP5.*;
import java.util.List;

// Basic controls. 
ControlP5 cp5;
ControlP5 cp5setZebrasReproductionRate;
ControlP5 cp5setLionsMortalityRate;

// Arrays for storing both types of species.
ArrayList<Zebra> zebras;
ArrayList<Lion> lions;

FoodSystem system;

int hungryZebra, hungryLion;
int wait;

boolean showRange = false;
String currentButton = "";

// Images for the background, and cursor actions, respectively.
PImage terrain;
PImage cursor1;
PImage cursor2;

void setup() {
  // size(1800, 900, P2D);
  fullScreen(P2D);
  zebras = new ArrayList();
  lions = new ArrayList();
  system = new FoodSystem();  
  initControls();

  hungryZebra = 5*100;//int(random(0, 50))*100;
  hungryLion  = int(random(0, 80))*100;

  wait = 1000;
  
  terrain = loadImage("terrain.png");
  cursor1 = loadImage("hand.png");
  cursor2 = loadImage("hand2.png");
  
  cursor(cursor1);
}

void draw() {
  imageMode(CORNER);
  image(terrain, 0, 0, width, height);  
  terrain.resize(width, height);
  
  ArrayList<Lion> danger=new ArrayList();

  for (Zebra z : zebras) {
    if(!z.isDead()){
      z.flock(zebras);
      z.update();
      z.borders();
      z.display();
      danger=z.alert(lions);
      
      if (hungryZebra == 0) {
        z.starving(system.foods);
      }
    }
  }

  for (Lion l : lions) {
    l.flock(lions);
    l.update();
    l.borders();
    l.display();

    if (hungryLion == 0) {
      l.starving(zebras);
    }
  }
  
  for (Food f : system.foods) {
    if (!f.isEmpty()){
      f.draw();
    }   
  }

  showHungerTimes();

  ArrayList<Zebra> zebrasToBeAdded = new ArrayList();
  int counterZ = 0;
  for (Iterator<Zebra> it = zebras.iterator(); it.hasNext(); ) {
    Zebra z = it.next();
    if (danger.isEmpty() && counterZ != 1 && zebras.size() > 1) {
      zebrasToBeAdded = z.reproduce(zebrasToBeAdded); 
      counterZ++;
    }
  }
  zebras.addAll(zebrasToBeAdded);

  int counterL = 0;
  for (Iterator<Lion> it = lions.iterator(); it.hasNext(); ) {
    Lion l = it.next();
    if (counterL != 1 && frameCount % l.hungerLevel == 0) {  
      it.remove();
      counterL++;
    }
  }  
  
  
  addItems();
}

// Shows the different hunger times of both species.
void showHungerTimes(){
  if (hungryLion != 0) {
    textSize(20);
    hungryLion--;
    text("Hunger time of lions: " + int(hungryLion/100), 10, 30);
  }

  if (hungryZebra != 0) {
    textSize(20);
    hungryZebra--;
    text("Hunger time of zebras: " + int(hungryZebra/100), 400, 30);
  }

  if (hungryLion == 0 && hungryZebra == 0) {
    textSize(32);
    wait--;
    text("General hunger time: " + int(wait/10), 10, 30);

    if (wait == 0) {
      hungryZebra = int(random(0, 50))*100;
      hungryLion = int(random(0, 50))*100;
      wait = 1000;
    }
  }
}

// Adds items on the screen depending on the button that is pressed.
void addItems(){
  if(mousePressed && notCloseToControls()){    
    if(currentButton.equals("Lion")){
      Lion l = new Lion(mouseX, mouseY, PVector.random2D(), 0.8, 0.1);
      l.debug = showRange;
      lions.add(l);
    }
    else if(currentButton.equals("Zebra")){
      Zebra z = new Zebra(mouseX, mouseY, PVector.random2D(), 0.7, 0.1);
      z.debug = showRange;
      zebras.add(z);
    }
    else if(currentButton.equals("Food")){
      system.addFood(mouseX, mouseY, "food");
    }
    else if(currentButton.equals("Water")){
      system.addFood(mouseX, mouseY, "water");
    }    
  }
}

// Methods for showing a "click" effect.
void mousePressed(){
  cursor(cursor2);
}

void mouseReleased(){
  cursor(cursor1);
}

// Verifies that the cursor isn't close to the sliders or buttons.
boolean notCloseToControls(){
  // Not close to the sliders.
  boolean closeToSliders = (!((100 < mouseX && mouseX < 800) && (0 < mouseY && mouseY < 100)));
  // Not close to the buttons.
  boolean closeToButtons = (!((width - 500 < mouseX && mouseX < width - 200) && (0 < mouseY && mouseY < 100)));
  return  closeToSliders && closeToButtons;
}

// Creates different controls.
void initControls() { 
  cp5 = new ControlP5(this);

  // Reproduction rate of the zebras.
  cp5setZebrasReproductionRate = new ControlP5(this);
  cp5setZebrasReproductionRate.addSlider("setReproductionRate")
    .setPosition(100, 50)
    .setSize(100, 20)
    .setRange(50, 1200)
    .setValue(500)
    .setCaptionLabel("Reproduction delay of zebras");

  cp5setLionsMortalityRate = new ControlP5(this);
  cp5setLionsMortalityRate.addSlider("setLionsMortalityRate")
    .setPosition(400, 50)
    .setSize(100, 20)
    .setRange(80, 2000)
    .setValue(300)
    .setCaptionLabel("Mortality delay of lions");  

  // Switch.
  cp5.addToggle("showRanges")
    .setPosition(700, 50)
    .setSize(50, 20)
    .setValue(showRange)
    .setMode(ControlP5.SWITCH)
    .setCaptionLabel("Show ranges");
    
  // Buttons.  
  cp5.addButton("buttonZebra")
     .setPosition(width - 500, 10)
     .setImages(loadImage("zebraBtn.png"), loadImage("zebraBtn.png"), loadImage("zebraBtn.png"))
     .updateSize();
     
  cp5.addButton("buttonLion")
     .setPosition(width - 400, 10)
     .setImages(loadImage("lionBtn.png"), loadImage("lionBtn.png"), loadImage("lionBtn.png"))
     .updateSize();     
     
  cp5.addButton("buttonFood")
     .setPosition(width - 300, 10)
     .setImages(loadImage("foodBtn.png"), loadImage("foodBtn.png"), loadImage("foodBtn.png"))
     .updateSize();
     
  cp5.addButton("buttonWater")
     .setPosition(width - 200, 10)
     .setImages(loadImage("waterBtn.png"), loadImage("waterBtn.png"), loadImage("waterBtn.png"))
     .updateSize();    
}

// Methods for configuring the different sliders.
void setReproductionRate(float val) {
  for (Zebra z : zebras) {
    z.reproductionRate = val;
  }
}

void setLionsMortalityRate(float val) {
  for (Lion l : lions) {
    l.hungerLevel = val;
  }
}

void showRanges(boolean val) {
  showRange = val;
  for (Zebra z : zebras) {   
    z.debug = val;
  }
  for (Lion l : lions) {
    l.debug = val;
  }
}

// Sets as "current button" the button that was pressed.
public void controlEvent(ControlEvent event) {
  String button = event.getController().getName();
  if(button.equals("buttonLion"))       currentButton = "Lion";
  else if(button.equals("buttonZebra")) currentButton = "Zebra";
  else if(button.equals("buttonFood"))  currentButton = "Food";
  else if(button.equals("buttonWater")) currentButton = "Water";
}
