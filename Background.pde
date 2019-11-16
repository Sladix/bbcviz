class Background{
  ArrayList<Line> lines;
  int res = 100;
  float h;
  float oy = 0;
  
  Background(int amount){
    lines = new ArrayList<Line>();
    
    h = height / float(amount);
    for(int y = 0; y < amount+4; y++){
      PVector start = new PVector(0, (y-2)*h + h/2);
      PVector end = new PVector(width, (y-2)*h + h/2);
      lines.add(new Line(start, end, res, h));
    }
  }
  
  void run(ArrayList<Particle> particles){
    oy -= 0.001+scoreGlobal*0.05;
    for (int i = lines.size()-1; i >= 0; i--) {
      Line l = lines.get(i);
      pushMatrix();
      strokeWeight(1+2*scoreGlobal);
      l.run(particles, oy);
      popMatrix();
    }
  }
}
