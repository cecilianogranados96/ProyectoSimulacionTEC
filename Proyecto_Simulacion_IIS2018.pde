import controlP5.*;
import java.util.List;
ControlP5 cp5;
ControlP5 cp5setZebrasReproductionRate;
ControlP5 cp5setLionsMortalityRate;

ArrayList<Zebra> zebras;
ArrayList<Lion> lions;
FoodSystem system;
int hungryZebra, hungryLion;
int wait;
boolean showRange = false;

void setup() {
  //size(800, 600);
  fullScreen(P2D);
  zebras = new ArrayList();
  lions = new ArrayList();
  system = new FoodSystem();
  background(0);
  initControls();
  
  hungryZebra = int(random(0, 50))*100;
  hungryLion = int(random(0, 80))*100;
  
  wait = 1000;
}

void draw() {
  background(0);

  for (Zebra z : zebras) {
    z.flock(zebras);
    z.update();
    z.borders();
    z.display();
    
    for (Food f : system.foods) {
      f.draw();
      
      if(hungryZebra == 0) {
        z.arrive(f.getPos());
      }
    }
  }
  
  for (Lion l : lions) {
    l.flock(lions);
    l.update();
    l.borders();
    l.display();
    
    if(hungryLion == 0) {
      for(Zebra z : zebras) {      
        l.arrive(z.getPos());
      }
    }
  }
  
  if(hungryLion != 0) {
    textSize(20);
    hungryLion--;
    text("Hunger time of lions: " + int(hungryLion/100), 10, 30);
  }
  
  if(hungryZebra != 0) {
    textSize(20);
    hungryZebra--;
    text("Hunger time of zebras: " + int(hungryZebra/100), 400, 30);
  }
  
  if(hungryLion == 0 && hungryZebra == 0) {
    textSize(32);
    wait--;
    text("General hunger time: " + int(wait/10), 10, 30);
    
    if(wait == 0) {
      hungryZebra = int(random(0, 50))*100;
      hungryLion = int(random(0, 50))*100;
      wait = 1000;
    }
  }
  
  ArrayList<Zebra> zebrasToBeAdded = new ArrayList();
  int counterZ = 0;
  for (Iterator<Zebra> it = zebras.iterator(); it.hasNext(); ) {
    Zebra z = it.next();
    if (!z.alert(lions) && counterZ != 1 && zebras.size() > 1) {
      zebrasToBeAdded = z.reproduce(zebrasToBeAdded); 
      counterZ++;
    }
  }
  zebras.addAll(zebrasToBeAdded);
  
  int counterL = 0;
  for (Iterator<Lion> it = lions.iterator(); it.hasNext(); ) {
    Lion l = it.next();
    if (l.starving(zebras) && counterL != 1 && frameCount % l.hungerLevel == 0) {  
      it.remove();
      counterL++;
    }
  }
  
  if (mousePressed && keyPressed) {
    if (mouseButton == LEFT  && zebras.size() < 55 && key == 'a') {
      Zebra z = new Zebra(mouseX, mouseY, PVector.random2D(), 0.3, 0.05);
      z.debug = showRange;
      zebras.add(z);
    } else if (mouseButton == RIGHT  && lions.size() < 25 && key == 'a') {
      Lion l = new Lion(mouseX, mouseY, PVector.random2D(), 0.5, 0.05);
      l.debug = showRange;
      lions.add(l);
    } else if (mouseButton == LEFT && key == ' ') {
      system.addFood(mouseX, mouseY);
    }
  } 
}

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

  cp5.addToggle("showRanges")
    .setPosition(700, 50)
    .setSize(50, 20)
    .setValue(showRange)
    .setMode(ControlP5.SWITCH)
    .setCaptionLabel("Show ranges");
}

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
