class Line{
  PVector start;
  PVector end;
  int res;
  PVector[] points;
  float h;
  float ns = 0.005;
  color c = color(150, 0, 0);
  float maxDist = 50;
  
  Line(PVector _start, PVector _end, int _res, float _h){
    res = _res;
    h = _h;
    start = _start.copy();
    end = _end.copy();
    points = new PVector[_res+1];
    float s = (end.x - start.x) / float(_res);
    for(int i = 0; i < res+1; i++){
      points[i] = new PVector(i*s, start.y + random(10));
      println(i*s);
    }
  }
  
  void run(ArrayList<Particle> particles, float oy){
    update(particles, oy);
    display();
  }
  
  void update(ArrayList<Particle> particles, float oy){
    for(int i = 0; i < res+1; i++){
      float nv = noise(points[i].x * ns, start.y * ns + oy);
      float nx = map(nv, 0 ,1, -1, 1);
      points[i].y = start.y + nx * 100 + random(currentLow*(h/4));
      for (Particle p : particles) {
        if(p.position.dist(new PVector(points[i].x, points[i].y)) < 50){
          points[i].y += pow(currentHi, 2)*maxDist;
          break;
        }
      }
    }
  }
  
  void display(){
    pushMatrix();
    noFill();
    stroke(c);
    beginShape();
    for(int i = 0; i < res+1; i++){
      curveVertex(points[i].x, points[i].y);
    }
    endShape();
    popMatrix();
  }
}
