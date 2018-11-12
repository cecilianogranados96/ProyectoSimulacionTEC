class Zebra implements IIndividuo {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  float r = 3;
  float maxSpeed;
  float maxForce;
  boolean alert, hungry;

  float alignmentDistance;
  float alignmentRatio;

  float separationDistance;
  float separationRatio;

  float cohesionDistance;
  float cohesionRatio;

  float arrivalRadius;

  float perceptionRadius;
  float reproductionRate;

  boolean debug;
  
  PImage img;
  
  int quantity;
  boolean dead;

  Zebra(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);

    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;

    separationDistance = 50;
    separationRatio = 25;

    alignmentDistance = 110;
    alignmentRatio = 0.5;

    cohesionDistance = 150;
    cohesionRatio = 0.1;

    arrivalRadius = 200;

    perceptionRadius = 75;
    reproductionRate = 500;
    
    img = loadImage("zebra.png");
    img.resize(20, 25);
    
    dead = false;
    quantity = 50;
  }

  boolean isDead() {
    return dead;
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    //PVector f = PVector.div(force, mass); xq mass es 1
    acc.add(force);
  }
  
  void starving(ArrayList<Food> foods) {
    float distance;
    for (Food f : foods) {
      distance = PVector.dist(f.getPos(), pos);
      if (distance <= perceptionRadius && !f.isEmpty()) {
        arrive(f.getPos(), f);
      }
    }
  }

  void arrive(PVector target, Food food) {
    PVector desired = PVector.sub(target, pos);
    float d = PVector.dist(pos, target);
    d = constrain(d, 0, arrivalRadius);
    float speed = map(d, 0, arrivalRadius, 0, maxSpeed);
    vel.setMag(speed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
    
    if(int(d) == 0){
      eat(food);
    }
  }

  void display() {
    float ang = vel.heading();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(ang);
    image(img, 0, 0, img.width, img.height);
    
    textSize(35);
    text(quantity, pos.x, pos.y);

    if (debug) {
      noFill();
      strokeWeight(1);
      stroke(#077EF2, 200);
      ellipse(0, 0, perceptionRadius * 2, perceptionRadius * 2);
    }

    popMatrix();
  }

  void borders() {
   if (pos.x > width - 50)  applyForce(new PVector(-1, 0));
   if (pos.x <= 0 + 50)     applyForce(new PVector(1, 0));
   if (pos.y > height - 50) applyForce(new PVector(0, -1));
   if (pos.y <= 0 + 50)     applyForce(new PVector(0, 1));
   }

  void align(ArrayList<Zebra> zebras) {
    PVector average = new PVector(0, 0);
    int count = 0;
    for (Zebra z : zebras) {
      float d = PVector.dist(pos, z.pos);
      if (this != z && d < alignmentDistance) {
        average.add(z.vel);
        count++;
      }
    }
    if (count > 0) {
      average.div(count);
      average.mult(alignmentRatio);
      average.limit(maxSpeed);
      applyForce(average);
    }
  }

  void separate(ArrayList<Zebra> zebras) {
    PVector average = new PVector(0, 0);
    int count = 0;
    for (Zebra z : zebras) {
      float d = PVector.dist(pos, z.pos);
      if (this != z && d < separationDistance) {
        PVector difference = PVector.sub(pos, z.pos);
        difference.normalize();
        difference.div(d);
        average.add(difference);
        count++;
      }
    }
    if (count > 0) {
      average.div(count);
      average.mult(separationRatio);
      average.limit(maxSpeed);
      applyForce(average);
    }
  }

  void cohere(ArrayList<Zebra> zebras) {
    PVector center = new PVector(0, 0);
    int count = 0;
    for (Zebra z : zebras) {
      float d = PVector.dist(pos, z.pos);
      if (this != z && d < cohesionDistance) {
        center.add(z.pos);
        count++;
      }
    }
    if (count > 0) {
      center.div(count);
      PVector force = center.sub(pos);
      force.mult(cohesionRatio);
      force.limit(maxSpeed);
      applyForce(force);
    }
  }

  void flock(ArrayList<Zebra> zebras) {
    separate(zebras);
    align(zebras);
    cohere(zebras);
  }

  ArrayList<Lion> alert(ArrayList<Lion> lions) {
    float distance;
    ArrayList<Lion> danger= new ArrayList();
    for (Lion l : lions) {
      distance=PVector.dist(l.pos, pos);
      if (distance<=perceptionRadius) {
        scape(l);
        danger.add(l);
      }
    }
    return danger;
  }

  void scape(Lion l) {
    PVector r = PVector.sub(pos, l.pos);
    float d = r.magSq();
    d = constrain(d, 1, 500);
    r.normalize();
    r.mult(100);//r.mult(G * a1.mass * a2.mass);
    r.div(d);
    applyForce(r);
  }

  /*boolean alert(ArrayList<Lion> lions) {
   for (Lion l : lions) {
   float lionPosX = l.pos.x;
   float lionPosY = l.pos.y;
   float leftSide = pos.x - perceptionRadius;
   float rightSide = pos.x + perceptionRadius; 
   float topSide = pos.y - perceptionRadius;
   float bottomSide = pos.y + perceptionRadius;
   
   if (leftSide <= lionPosX && lionPosX <= rightSide && topSide <= lionPosY && lionPosY <= bottomSide) {  
   return true;
   }
   }
   return false;
   }*/

  ArrayList<Zebra> reproduce(ArrayList<Zebra> zebrasToBeAdded) {     
    if (frameCount % reproductionRate == 0) {
      zebrasToBeAdded.add(new Zebra(pos.x+15, pos.y+15, PVector.random2D(), 0.7, 0.1));
    }
    return zebrasToBeAdded;
  }

  PVector getPos() {
    return pos;
  }
  
  void eat(Food food) {
    food.eating();
  }
  
  void eating(){
    quantity--;
    
    if(quantity == 0){
      dead = true;
    }
  }
}
