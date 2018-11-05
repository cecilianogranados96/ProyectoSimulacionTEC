class Lion implements IIndividuo {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass = 1;
  float r = 3;
  float maxSpeed;
  float maxForce;
  boolean alive, hungry;
  
  float alignmentDistance;
  float alignmentRatio;
  
  float separationDistance;
  float separationRatio;
  
  float cohesionDistance;
  float cohesionRatio;
  
  float arrivalRadius;
  float perceptionRadius;
  float hungerLevel;
  
  color c;
  boolean debug;
  
  Lion(float x, float y, PVector vel, float maxSpeed, float maxForce) {
    pos = new PVector(x, y);
    this.vel = vel;
    acc = new PVector(0, 0);
    
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    
    separationDistance = 50;
    separationRatio = 1;
    
    alignmentDistance = 70;
    alignmentRatio = 1;
    
    cohesionDistance = 10;
    cohesionRatio = 1;
    
    arrivalRadius = 200;
    perceptionRadius = 300;
    hungerLevel = 300;
    c = color(#C0C40C);
  }
  
  //void update() {
  //  if (hungry) {
  //    //busca comida
  //    seek();
  //  }
  //}
  
  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }
  
  boolean isDead() {
    return !alive;
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
      strokeWeight(1);
      //stroke(255, 0, 0, 100);
      //ellipse(0, 0, cohesionDistance * 2, cohesionDistance * 2);
      //stroke(0, 255, 0, 100);
      //ellipse(0, 0, alignmentDistance * 2, alignmentDistance * 2);
      //stroke(128, 128, 255, 100);
      //ellipse(0, 0, separationDistance * 2, separationDistance * 2);      
      stroke(#F51616);
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
      average.setMag(alignmentRatio);
      average.limit(maxForce);
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
      average.setMag(separationRatio);
      average.limit(maxForce);
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
  
  void flock(ArrayList<Lion> lions) {
    separate(lions);
    align(lions);
    cohere(lions);
  }
  
  boolean starving(ArrayList<Zebra> zebras) {
    for (Zebra z : zebras) {
      float zebraPosX = z.pos.x;
      float zebraPosY = z.pos.y;
      float leftSide = pos.x - perceptionRadius;
      float rightSide = pos.x + perceptionRadius; 
      float topSide = pos.y - perceptionRadius;
      float bottomSide = pos.y + perceptionRadius;

      if (leftSide <= zebraPosX && zebraPosX <= rightSide && topSide <= zebraPosY && zebraPosY <= bottomSide) {  
        return false;
      }
    }
    return true;
  }
  
  void eliminate(){
    if(frameCount % hungerLevel == 0){
      
    }
  }
}
