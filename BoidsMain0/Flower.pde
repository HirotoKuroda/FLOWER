
class Flower{
  
  boolean exit = false;
  boolean dead = false;
  
  int f_size = 12;
  int count = 0;
  
  float x;
  float y;
  
  color f_color;
  float r = 0;
  float g = 0;
  float b = 0;
  
  Flower(){
    init();
  }
  
  void init(){
    
    this.x = random(width);
    this.y = random(height-50);
    
    r = random(200, 255);
    g = random(80, 120);
    b = random(130, 200);
    
    f_color = color(r, g, b);
  }
  
  void Exit(){
    exit = true;
  }
  
  void Color_Dead(){
    count++;
    
    if(count == 150){
      dead = true;
      f_color = color(255);
    }
  }
  
  void born(Flower f){
    this.x = f.x + random(-40, 40);
    while(this.x > width || this.x < 0){
      this.x = f.x + random(-40, 40);
    }
    this.y = f.y + random(-40, 40);
    while(this.y > height || this.y < 0){
      this.y = f.y + random(-40, 40);
    }
    Exit();
  }
  
}
    
