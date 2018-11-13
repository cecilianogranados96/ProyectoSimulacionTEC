class Lion {
  PVector pos;
  PVector vel;
  PVector acc;
  float r = 3;
  float maxSpeed;
  float maxForce;
  boolean dead, hunting;

  float alignmentDistance;
  float alignmentRatio;

  float separationDistance;
  float separationRatio;

  float cohesionDistance;
  float cohesionRatio;

  float arrivalRadius;
  float perceptionRadius;
  float hungerLevel;
  
  boolean debug;
  
  PImage img;

  Lion(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);

    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;

    separationDistance = 20;
    separationRatio = 10;

    alignmentDistance = 70;
    alignmentRatio = 1;

    cohesionDistance = 200;
    cohesionRatio = 0.01;

    arrivalRadius = 100;
    perceptionRadius = 150;
    hungerLevel = 300;    
    
    img = loadImage("lion.png");
    img.resize(25, 30);
    hunting=false;
    dead = false;
  }

  void update() {
    vel.add(acc);
    if(!hunting){
      vel.limit(maxSpeed);
    }else{
     vel.limit(1.2); 
    }
    pos.add(vel);
    acc.mult(0);
  }

  boolean isDead() {
    return dead;
  }

  void applyForce(PVector force) {
    acc.add(force);
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
      stroke(#F51616, 200);
      ellipse(0, 0, perceptionRadius, perceptionRadius);
    }

    popMatrix();
  }

  void borders() {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
    /*if(pos.x > width - 50)  applyForce(new PVector(-1, 0));
    if(pos.x <= 0 + 50)     applyForce(new PVector(1, 0));
    if(pos.y > height - 50) applyForce(new PVector(0, -1));
    if(pos.y <= 0 + 50)     applyForce(new PVector(0, 1));*/
  }

  void align(ArrayList<Lion> lions) {
    PVector average = new PVector(0, 0);
    int count = 0;
    for (Lion l : lions) {
      float d = PVector.dist(pos, l.pos);
      if (this != l && d < alignmentDistance) {
        average.add(l.vel);
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

  void separate(ArrayList<Lion> lions) {
    PVector average = new PVector(0, 0);
    int count = 0;
    for (Lion l : lions) {
      float d = PVector.dist(pos, l.pos);
      if (this != l && d < separationDistance) {
        PVector difference = PVector.sub(pos, l.pos);
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

  void cohere(ArrayList<Lion> lions) {
    PVector center = new PVector(0, 0);
    int count = 0;
    for (Lion l : lions) {
      float d = PVector.dist(pos, l.pos);
      if (this != l && d < cohesionDistance) {
        center.add(l.pos);
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

  void arrive(PVector target, Zebra zebra) {
    PVector desired = PVector.sub(target, pos);
    float d = PVector.dist(pos, target);
    d = constrain(d, 0, arrivalRadius);
    float speed = map(d, 0, arrivalRadius, 0, maxSpeed);
    vel.setMag(speed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
    
    if(abs(int(d)) == 10){
      eat(zebra);
    }
  }
  
  void eat(Zebra zebra) {
    zebra.eating();
  }

  void flock(ArrayList<Lion> lions) {
    separate(lions);
    //align(lions);
    //cohere(lions);
  }

  void starving(ArrayList<Zebra> zebras) {
    float distance;
    int zebrasToEat=0;
    for (Zebra z : zebras) {
      distance = PVector.dist(z.pos, pos);
      if (distance <= perceptionRadius && !z.isDead()) {
        hunting=true;
        arrive(z.getPos(), z);
        zebrasToEat++;
      }
    }
    if(zebrasToEat==0){
     hunting=false; 
    }
  }
  
  boolean target(ArrayList<Zebra> zebras) {
    float distance;
    
    for (Zebra z : zebras) {
      distance = PVector.dist(z.pos, pos);
      if (distance <= perceptionRadius && !z.isDead()) {
        return true;
      }
    }
    return false;
  }
  
  PVector getPos(){
    return pos;
  }

  void eliminate() {
    if (frameCount % hungerLevel == 0) {
    }
  }
}
