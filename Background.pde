class Background{
  ArrayList<Line> lines;
  int res = 100;
  
  Background(int amount){
    lines = new ArrayList<Line>();
    
    float h = height / float(amount);
    println(h);
    println(height);
    println(amount);
    for(int y = 0; y < amount+4; y++){
      PVector start = new PVector(0, (y-2)*h + h/2);
      PVector end = new PVector(width, (y-2)*h + h/2);
      lines.add(new Line(start, end, res, h));
    }
  }
  
  void run(){
    for (int i = lines.size()-1; i >= 0; i--) {
      Line l = lines.get(i);
      l.run();
    }
  }
}
