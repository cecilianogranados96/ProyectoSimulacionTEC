class Zebra implements IIndividuo {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  float r = 3;
  float maxSpeed;
  float maxForce;
  boolean alive, alert;
  
  float alignmentDistance;
  float alignmentRatio;
  
  float separationDistance;
  float separationRatio;
  
  float cohesionDistance;
  float cohesionRatio;
  
  float arrivalRadius;
  
  float perceptionRadius;
  float reproductionRate;
  
  color c;
  boolean debug;
  
  Zebra(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);
    
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    
    separationDistance = 20;
    separationRatio = 1;
    
    alignmentDistance = 70;
    alignmentRatio = 1;
    
    cohesionDistance = 70;
    cohesionRatio = 1;
    
    arrivalRadius = 200;
    
    perceptionRadius = 200;
    reproductionRate = 500;
    
    c = color(255);
  }
  
  //void update() {
  //  if (alert) {
  //    //aumenta velocidad xq la vio un leon
  //  }
  //  if (hungry) {
  //    //busca comida
  //    seek();
  //  }
  //}

  boolean isDead() {
    return !alive;
  }
  
  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }
  
  void seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    desired.setMag(maxSpeed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
  }
  
  void display() {
    float ang = vel.heading();
    noStroke();    
    fill(c);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(ang);
    beginShape();
    vertex(r * 3, 0);
    vertex(0, -r);
    vertex(0, r);
    endShape(CLOSE);
    
    if (debug) {
      noFill();
      //strokeWeight(1);
      //stroke(255, 0, 0, 100);
      //ellipse(0, 0, cohesionDistance * 2, cohesionDistance * 2);
      //stroke(0, 255, 0, 100);
      //ellipse(0, 0, alignmentDistance * 2, alignmentDistance * 2);
      //stroke(128, 128, 255, 100);
      //ellipse(0, 0, separationDistance * 2, separationDistance * 2);
      stroke(128, 128, 255, 100);
      ellipse(0, 0, perceptionRadius * 2, perceptionRadius * 2);      
    }
    
    popMatrix();
  }
  
  void borders() {
    if(pos.x > width - 50)  applyForce(new PVector(-1, 0));
    if(pos.x <= 0 + 50)     applyForce(new PVector(1, 0));
    if(pos.y > height - 50) applyForce(new PVector(0, -1));
    if(pos.y <= 0 + 50)     applyForce(new PVector(0, 1));
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
      average.setMag(alignmentRatio);
      average.limit(maxForce);
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
      average.setMag(separationRatio);
      average.limit(maxForce);
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
      force.setMag(cohesionRatio);
      force.limit(maxForce);
      applyForce(force);
    }
  }
  
  void arrive(PVector target) {
    PVector desired = PVector.sub(target, pos);
    float d = PVector.dist(pos, target);
    d = constrain(d, 0, arrivalRadius);
    float speed = map(d, 0, arrivalRadius, 0, maxSpeed);
    vel.setMag(speed);
    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    applyForce(steering);
  }
  
  void flock(ArrayList<Zebra> zebras) {
    separate(zebras);
    align(zebras);
    cohere(zebras);
  }
  
  boolean alert(ArrayList<Lion> lions) {
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
  }
  
  ArrayList<Zebra> reproduce(ArrayList<Zebra> zebrasToBeAdded) {     
    if (frameCount % reproductionRate == 0) {
      zebrasToBeAdded.add(new Zebra(pos.x+15, pos.y+15, PVector.random2D(), 0.15, 0.05));
    }
    return zebrasToBeAdded;
  }
  
  PVector getPos() {
    return pos;
  }
}
