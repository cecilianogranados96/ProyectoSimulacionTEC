class Zebra {
  PVector pos;
  PVector vel;
  PVector acc;
  float r = 3;
  float maxSpeed;
  float maxForce;
  boolean alert;
  boolean eat;
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

    separationDistance = 100;
    separationRatio = 100;

    alignmentDistance = 110;
    alignmentRatio = 0.5;

    cohesionDistance = 100;
    cohesionRatio = 0.05;

    arrivalRadius = 200;

    perceptionRadius = 100;
    reproductionRate = 500;

    img = loadImage("zebra.png");
    img.resize(20, 25);
    alert=false;
    dead = false;
    eat = false;
    quantity = 10;
  }

  void draw(ArrayList<Zebra> zebras) {
    if (!dead) {
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
    if (!alert) {
      vel.limit(maxSpeed);
    } else {
      vel.limit(1.1);
    }
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void starving(ArrayList<Food> foods, ArrayList zebras) {
    float distance;
    for (Food f : foods) {
      distance = PVector.dist(f.getPos(), pos);
      if (distance <= perceptionRadius && !f.isEmpty()) {
         separationRatio = 50;
        arrive(f.getPos(), f);
        maxSpeed = 0;
      }
      else{
        maxSpeed = 0.7;
        separationRatio =100;
      }
      
    }
    maxSpeed = 0.7;
    separationRatio =100;
    flock(zebras);
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
    if (int(d) == 0) {
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
    }

    popMatrix();
  }

  void borders() {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
    /*if (pos.x > width - 50)  applyForce(new PVector(-1, 0));
     if (pos.x <= 0 + 50)     applyForce(new PVector(1, 0));
     if (pos.y > height - 50) applyForce(new PVector(0, -1));
     if (pos.y <= 0 + 50)     applyForce(new PVector(0, 1));*/
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
    if (!alert) {
      separate(zebras);
      align(zebras);
      cohere(zebras);
    }
  }

  boolean alert(ArrayList<Lion> lions) {
    float distance;
    int danger=0;
    for (Lion l : lions) {
      distance = PVector.dist(l.pos, pos);
      if (distance <= perceptionRadius && !l.isDead()) {
        alert=true;
        escape(l);
        danger++;
      }
    }
    if (danger==0) {
      alert=false;
    }
    return alert;
  }

  void escape(Lion l) {
    PVector r = PVector.sub(l.pos, pos);
    float d = r.magSq();
    d = constrain(d, 1, 500);
    r.normalize();
    r.mult(-10);//r.mult(G * a1.mass * a2.mass);
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

  void eating() {
    quantity--;

    if (quantity == 0) {
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
