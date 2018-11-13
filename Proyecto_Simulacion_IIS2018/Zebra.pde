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

    separationDistance = 200;
    separationRatio = 100;

    alignmentDistance = 70;
    alignmentRatio = 1;

    cohesionDistance = 200;
    cohesionRatio = 0.1;

    arrivalRadius = 100;

    perceptionRadius = 100;
    reproductionRate = 500;
    
    img = loadImage("zebra.png");
    img.resize(20, 25);
    
    dead = false;
    quantity = 10;
  }
  
  void draw(ArrayList<Zebra> zebras){
    if(!dead){
      flock(zebras);
      update();
      borders();
    }
    
    display();
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
    PVector f = PVector.div(force, mass);
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
    imageMode(CENTER);
    image(img, 0, 0, img.width, img.height);
    imageMode(CORNER);

    if (debug) {
      noFill();
      strokeWeight(1);
      stroke(#077EF2, 200);
      ellipse(0, 0, perceptionRadius, perceptionRadius);
      
      /*stroke(#009473, 200);
      ellipse(0, 0, separationDistance, separationDistance);
      
      stroke(#ff66c1, 200);
      ellipse(0, 0, alignmentDistance, alignmentDistance);
      
      stroke(#f2de15, 200);
      ellipse(0, 0, cohesionDistance, cohesionDistance);*/
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
      if (this != z && d < alignmentDistance && !z.isDead()) {
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
    ArrayList<Lion> danger = new ArrayList();
    for (Lion l : lions) {
      distance = PVector.dist(l.pos, pos);
      if (distance <= perceptionRadius) {
        scape(l);
        danger.add(l);
        maxSpeed = 1.4;
        l.maxSpeed = 1.5;
      }
      else {
        maxSpeed = 0.7;
        l.maxSpeed = 0.8;
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
      img = loadImage("dead.png");
      img.resize(30, 35);
    }
  }
  
  boolean target(ArrayList<Food> foods) {
    float distance;
    for (Food f : foods) {
      distance = PVector.dist(f.pos, pos);
      if (distance <= perceptionRadius && !f.isEmpty()) {
        return true;
      }
    }
    return false;
  }
}
