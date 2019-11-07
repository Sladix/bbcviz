class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PImage image;
  float lifespan= 500.0;
  
  float xOff = 0, yOff = 0;

  Particle(PVector pos, PImage image) {
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    position = pos.copy();
    this.image = image;
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    /*
    float nx = map(this.position.x, 0, width, -1,1);
    float ny = map(this.position.y, 0, width, -1,1);
    */
    float ns = 0.006;
    int af = 4;
    
    float angle = noise((this.position.x + xOff)*ns, (this.position.y + yOff)*ns) * TWO_PI * af;
    acceleration = PVector.fromAngle(angle);
    
    acceleration.mult(0.5);
    velocity.add(acceleration);
    position.add(velocity);
    velocity.mult(0.9);
    acceleration.mult(0);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    //ellipse(position.x, position.y, log(scoreMid)*3, log(scoreMid)*3);
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading() + PI);
    tint(255, lifespan);
    image(image, 0, 0, bill.width/6, bill.height/6);
    popMatrix();
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
