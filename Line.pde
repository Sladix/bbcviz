class Line{
  PVector start;
  PVector end;
  int res;
  PVector[] points;
  float h;
  float ns = 0.005;
  float oy = 0;
  
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
  
  void run(ArrayList<Particle> particles){
    update(particles);
    display();
  }
  
  void update(ArrayList<Particle> particles){
    for(int i = 0; i < res+1; i++){
      float nv = noise(points[i].x * ns, start.y * ns + oy);
      float nx = map(nv, 0 ,1, -1, 1);
      points[i].y = start.y + nx * 100 + random(currentLow*(h/2));
      for (Particle p : particles) {
        if(p.position.dist(new PVector(points[i].x, points[i].y)) < 50){
          points[i].y += 20;
          break;
        }
      }
    }
    oy -= 0.001+currentLow*0.01;
  }
  
  void display(){
    pushMatrix();
    color c = color(50+currentMid*205, 0, 0);
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
