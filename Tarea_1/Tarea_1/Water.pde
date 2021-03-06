class Water implements Scene{

  //************* RIPPLE EFFECT ****************************//
  PImage img,bubble,coral;
  Ripple ripple;
  //************************** BUBBLES ************///
  ArrayList<Particle> pts;
  ArrayList<floatingObj> fts;
  boolean onPressed, showInstruction;
  PFont f1, f2;
  //******************************* VARIABLES MOVIMIENTO ***************************//
  float preivousJointPossition;
  //******************************* VARIABLES MOVIMIENTO ***************************//

  //****************************************** TIMER **************************************//
  int interval = 1500;//timer's interval
  int lastRecordedTime = 0;
  //****************************************** TIMER **************************************//

  boolean automaticWaves =false;

  public Water(){}

  void closeScene(){}
  void initialScene(){
    img = loadImage("data/ocean1.jpg");
    bubble =   loadImage("data/bubble.png");
    bubble.resize(50,50);
    coral = loadImage("data/coral.png");
    coral.resize(100,100);
    img.resize(width,height);

    ripple = new Ripple();

    //**************** BUBBLES ******************************//
    pts = new ArrayList<Particle>();
    showInstruction = true;
    //***************************** VARIABLES MOVIMIENTO **************************//
      preivousJointPossition = 0;
    //******************************* VARIABLES MOVIMIENTO ***************************//

    //************************ floatando
    fts = new ArrayList<floatingObj>() ;
    for (int i=0;i<3;i++) {
        floatingObj newP = new floatingObj(10 + i*100, height - 100, coral);
        fts.add(newP);
    }
  }

  void drawScene(){
    loadPixels();
    img.loadPixels();
    for (int loc = 0; loc < width * height; loc++) {
      pixels[loc] = ripple.col[loc];
    }
    updatePixels();

   //******************* BUBBLES***************************//
   if (onPressed) {
      for (int i=0;i<10;i++) {
        float x_coord  = map(head2d.x, 0, kWidth, 0, width);
        float y_coord = map(head2d.y, 0, kHeight, 0, height);
        Particle newP = new Particle(x_coord , y_coord, i+pts.size(), i+pts.size(),this.bubble);
        pts.add(newP);
      }
    }

    for (int i=0; i<pts.size(); i++) {
      Particle p = pts.get(i);
      p.update();
      p.display();
    }

    for (int i=pts.size()-1; i>-1; i--) {
      Particle p = pts.get(i);
      if (p.dead) {
        pts.remove(i);
      }
    }

    ripple.newframe();

    if(millis()-lastRecordedTime>interval){
     mouseMovedLZ(); // Para mostrar ripple effect
     mousePressedLZ(); // Para mostrar bubbles
     //and record time for next tick
     lastRecordedTime = millis();
    } else {
      mouseReleasedLZ();
    }
    mouseMovedLZ();
    mouseMovedAutomaticLZ();

    //*******************floating
    for (int i=0; i<fts.size(); i++) {
      floatingObj ft = fts.get(i);
      ft.update();
      if (!ft.dead || (ft.dead && ft.lifeTime >= 0)){
        ft.display();
      }
    }
  }

  String getSceneName(){return "Water";};

  class floatingObj {
    float y,x,g,acceleration,lifeTime;
    boolean active, dead;
    int factor;
    PImage img;
    floatingObj(float x,float y, PImage img) {
      this.x = x;
      this.y =y;
      this.active = false;
      this.g = .8;
      this.factor = -1;
      this.img = img;
      this.lifeTime = 150;
      this.dead = false;
    }

    void display(){
      image(this.img,this.x ,this.y);
    }

    void update(){
      if (!this.active) {
        this.y += this.factor;
        this.factor *= -1;
      }

      float x_coord_right  = map(rightHand2d.x, 0, kWidth, 0, width);
      float y_coord_right = map(rightHand2d.y, 0, kHeight, 0, height);
      
      float x_coord_left  = map(leftHand2d.x, 0, kWidth, 0, width);
      float y_coord_left = map(leftHand2d.y, 0, kHeight, 0, height);

      if ((Math.abs(y_coord_right - this.y) <=  100 && Math.abs(x_coord_right - this.x) <= 100) || (Math.abs(y_coord_left - this.y) <=  100 && Math.abs(x_coord_left - this.x) <= 100)){
        this.active = true;
      }

      if (this.active && (this.y - this.g > 200)){
        this.y -= this.g;
      } else if (this.active) {
        this.active = false;
        this.dead = true;
      }
      if (this.dead){
        this.lifeTime--;
      }
    }
  }

  class Ripple {
    int i, a, b;
    int oldind, newind, mapind;
    short ripplemap[]; // the height map
    int col[]; // the actual pixels
    int riprad;
    int rwidth, rheight;
    int ttexture[];
    int ssize;

    Ripple() {
      // constructor
      riprad = 3;
      rwidth = width >> 1;
      rheight = height >> 1;
      ssize = width * (height + 2) * 2;
      ripplemap = new short[ssize];
      col = new int[width * height];
      ttexture = new int[width * height];
      oldind = width;
      newind = width * (height + 3);
    }

    void newframe() {
      // update the height map and the image
      i = oldind;
      oldind = newind;
      newind = i;

      i = 0;
      mapind = oldind;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          short data = (short)((ripplemap[mapind - width] + ripplemap[mapind + width] +
            ripplemap[mapind - 1] + ripplemap[mapind + 1]) >> 1);
          data -= ripplemap[newind + i];
          data -= data >> 5;
          if (x == 0 || y == 0) // avoid the wraparound effect
            ripplemap[newind + i] = 0;
          else
            ripplemap[newind + i] = data;

          // where data = 0 then still, where data > 0 then wave
          data = (short)(1024 - data);

          // offsets
          a = ((x - rwidth) * data / 1024) + rwidth;
          b = ((y - rheight) * data / 1024) + rheight;

          //bounds check
          if (a >= width)
            a = width - 1;
          if (a < 0)
            a = 0;
          if (b >= height)
            b = height-1;
          if (b < 0)
            b=0;

          col[i] = img.pixels[a + (b * width)];
          mapind++;
          i++;
        }
      }
    }
  }

  //******************************* BUBBLES **************************************************//
  void mousePressed() {
    onPressed = true;
    if (showInstruction) {
      background(255);
      showInstruction = false;
    }
  }

  void mouseReleased() {
    onPressed = false;
  }

  void mousePressedLZ() {
    onPressed = true;
    if (showInstruction) {
      background(255);
      showInstruction = false;
    }
  }

  void mouseReleasedLZ() {
    onPressed = false;
  }

  void mouseMovedLZ(){
    float x_coord  = map(rightHand2d.x, 0, kWidth, 0, width);
    float y_coord = map(rightHand2d.y, 0, kHeight, 0, height);
    
    for (float j = y_coord - ripple.riprad; j < y_coord + ripple.riprad; j++) {
      for (float k = x_coord - ripple.riprad; k < x_coord + ripple.riprad; k++) {
        if (j >= 0 && j < height && k>= 0 && k < width) {
          ripple.ripplemap[(int)(ripple.oldind + (j * width) + k)] += 512;
        }
      }
    }
  }

  void mouseMovedAutomaticLZ(){
    for (int j = 0 - ripple.riprad; j < 10 + ripple.riprad; j++) {
      for (int k = 0 - ripple.riprad; k < width + ripple.riprad; k++) {
        if (j >= 0 && j < 10 && k>= 0 && k < width) {
          ripple.ripplemap[ripple.oldind + (j * width) + k] += 10 *k;
        }
      }
    }
  }
}
