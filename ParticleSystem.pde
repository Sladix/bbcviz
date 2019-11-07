class ParticleSystem {
  ArrayList<Particle> particles;
  PImage image;
  PVector origin;
  int numParts = 50;
  int limitParticles = 2000;
  
  float cx = 0, cy = 0;

  ParticleSystem(PVector location, PImage image) {
    origin = location.copy();
    particles = new ArrayList<Particle>();
    this.image = image;
  }

  void addParticle(float diam) {
    particles.add(new Particle(origin.copy().add(new PVector(random(-diam,diam),random(-diam,diam))), image));
  }
  
  void changeOffsets(){
    if(this.particles.size() < limitParticles){
      for(int i = 0; i < numParts; i++){
        addParticle(200);
      }
    }
    cx += 1337;
    cy += 7331;
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.xOff = cx;
      p.yOff = cy;
      p.velocity.add(new PVector(random(-20,20), random(-20,20)));
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
