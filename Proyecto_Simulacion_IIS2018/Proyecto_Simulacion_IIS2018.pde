import controlP5.*;
import java.util.List;

// Basic controls. 
ControlP5 cp5;
ControlP5 cp5setZebrasReproductionRate;
ControlP5 cp5setLionsMortalityRate;

// Arrays for storing both types of species.
ArrayList<Zebra> zebras;
ArrayList<Lion> lions;
ArrayList<Dead> dead;

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
  dead = new ArrayList();
  system = new FoodSystem();

  initControls();

  hungryZebra = 5*100;//int(random(0, 50))*100;
  hungryLion  = 5*100;//int(random(0, 80))*100;

  wait = 1000;

  terrain = loadImage("terrain.jpg");
  cursor1 = loadImage("hand.png");
  cursor2 = loadImage("hand2.png");

  cursor(cursor1);
}

void draw() {
  imageMode(CORNER);
  image(terrain, 0, 0, width, height);  
  terrain.resize(width, height);

  for (Dead d : dead) {
    d.draw();
  }

  for (Food f : system.foods) {
    if (!f.isEmpty()) {
      f.draw();
    }
  }

  for (Zebra z : zebras) {
    z.draw(zebras);
    boolean isAlert=z.alert(lions);
    if (hungryZebra == 0 && !(system.foods.isEmpty()) && !isAlert) {
      z.starving(system.foods, zebras);
    }
  }
  
  for (Lion l : lions) {
    l.flock(lions);
    l.update();
    l.borders();
    l.display();

    if (hungryLion == 0 && !(zebras.isEmpty())) {
      l.starving(zebras);
    }
  }
  showHungerTimes();

  // Reproduction of zebras.
  ArrayList<Zebra> zebrasToBeAdded = new ArrayList();
  int counterZ = 0;
  for (Iterator<Zebra> it = zebras.iterator(); it.hasNext(); ) {
    Zebra z = it.next();
    if (!z.alert(lions) && counterZ != 1 && zebras.size() > 1) { //if (z.alert(lions) && counterZ != 1 && zebras.size() > 1 && z.target(system.foods)) {
      zebrasToBeAdded = z.reproduce(zebrasToBeAdded); 
      counterZ++;
    }
  }
  zebras.addAll(zebrasToBeAdded);

  // Eliminates lions.
  int counterL = 0;
  for (Iterator<Lion> it = lions.iterator(); it.hasNext(); ) {
    Lion l = it.next();
    if (!l.target(zebras) && counterL != 1 && frameCount % l.hungerLevel == 0) {
      Dead d = new Dead(l.getPos().x, l.getPos().y);
      dead.add(d);
      it.remove();
      counterL++;
    }
  }

  //Add items
  if (mousePressed && notCloseToControls()) {    
    if (currentButton.equals("Lion")) {
      Lion l = new Lion(mouseX, mouseY, PVector.random2D(), 0.8, 0.1);
      l.debug = showRange;
      lions.add(l);
    } else if (currentButton.equals("Zebra")) {
      Zebra z = new Zebra(mouseX, mouseY, PVector.random2D(), 0.7, 0.1);
      z.debug = showRange;
      zebras.add(z);
    } else if (currentButton.equals("Food")) {
      system.addFood(mouseX, mouseY, "food");
    } else if (currentButton.equals("Water")) {
      system.addFood(mouseX, mouseY, "water");
    }
  }
  
  // Eliminates zebras.
  for (Iterator<Zebra> it = zebras.iterator(); it.hasNext(); ) {
    Zebra z = it.next();
    if (z.isDead()) {
      Dead d = new Dead(z.getPos().x, z.getPos().y);
      dead.add(d);
      it.remove();
    }
  }

  // Eliminates food.
  for (Iterator<Food> it = system.foods.iterator(); it.hasNext(); ) {
    Food f = it.next();
    if (f.isEmpty()) {
      it.remove();
    }
  }
}

// Shows the different hunger times of both species.
void showHungerTimes() {
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
      hungryZebra = int(random(0, 20))*100;
      hungryLion = int(random(0, 50))*100;
      wait = 1000;
    }
  }
}

// Adds items on the screen depending on the button that is pressed.
void addItems() {
  if (mousePressed && notCloseToControls()) {    
    if (currentButton.equals("Lion")) {
      Lion l = new Lion(mouseX, mouseY, PVector.random2D(), 0.8, 0.1);
      l.debug = showRange;
      lions.add(l);
    } else if (currentButton.equals("Zebra")) {
      Zebra z = new Zebra(mouseX, mouseY, PVector.random2D(), 0.7, 0.1);
      z.debug = showRange;
      zebras.add(z);
    } else if (currentButton.equals("Food")) {
      system.addFood(mouseX, mouseY, "food");
    } else if (currentButton.equals("Water")) {
      system.addFood(mouseX, mouseY, "water");
    }
  }
}

// Methods for showing a "click" effect.
void mousePressed() {
  cursor(cursor2);
}

void mouseReleased() {
  cursor(cursor1);
}

// Verifies that the cursor isn't close to the sliders or buttons.
boolean notCloseToControls() {
  // Not close to the sliders.
  boolean closeToSliders = (!((50 < mouseX && mouseX < 800) && (0 < mouseY && mouseY < 100)));
  // Not close to the buttons.
  boolean closeToButtons = (!((width - 650 < mouseX && mouseX < width - 250) && (0 < mouseY && mouseY < 100)));
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
    .setPosition(width - 600, 10)
    .setImages(loadImage("zebraBtn.png"), loadImage("zebraBtn.png"), loadImage("zebraBtn.png"))
    .updateSize();

  cp5.addButton("buttonLion")
    .setPosition(width - 500, 10)
    .setImages(loadImage("lionBtn.png"), loadImage("lionBtn.png"), loadImage("lionBtn.png"))
    .updateSize();     

  cp5.addButton("buttonFood")
    .setPosition(width - 400, 10)
    .setImages(loadImage("foodBtn.png"), loadImage("foodBtn.png"), loadImage("foodBtn.png"))
    .updateSize();

  cp5.addButton("buttonWater")
    .setPosition(width - 300, 10)
    .setImages(loadImage("waterBtn.png"), loadImage("waterBtn.png"), loadImage("waterBtn.png"))
    .updateSize();
    
  cp5.addButton("buttonClear")
    .setPosition(width - 200, 10)
    .setImages(loadImage("clearBtn.png"), loadImage("clearBtn.png"), loadImage("clearBtn.png"))
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

// Clears the screen.
void resetAll(){
  zebras = new ArrayList();
  lions  = new ArrayList();
  dead   = new ArrayList();
  system = new FoodSystem();
}

// Sets as "current button" the button that was pressed.
public void controlEvent(ControlEvent event) {
  String button = event.getController().getName();
  if (button.equals("buttonLion"))       currentButton = "Lion";
  else if (button.equals("buttonZebra")) currentButton = "Zebra";
  else if (button.equals("buttonFood"))  currentButton = "Food";
  else if (button.equals("buttonWater")) currentButton = "Water";
  else if (button.equals("buttonClear")) resetAll();
}
