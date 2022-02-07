#include "../lib/math/Line.cpp";
const int MAX_PLAYERS = 4;

const uint WHITE = 0xFFFFFFFF; 
const uint WHITE_TRANSPARENT = 0x4AFFFFFF;
const uint GREEN = 0xFF00FF00; 

class script : callback_base {
  scene@ g;
  [text] array<shootingStar> stars;
  [hidden] bool animate;
  [hidden] float timer;
  script() { 
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
    animate = false;
    timer = 0;
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('triggerType') == 'shootingStar') {
      if(msg.get_int('start') == 1) {
        animate = true;
      } else if (msg.get_int('stop') == 1) {
        animate = false;
        for(uint i = 0; i < stars.length(); i++) {
          stars[i].reset();
        }
      }
     }
  }
 
  void on_level_start() {
    animate = false;
  }

  void editor_step() {
  }

  void editor_draw(float sub_frame) {
    for(uint i = 0; i < stars.length(); i++) {
      if(stars[i].showLines) {
        g.draw_line_world(0, stars[i].sublayer, 
        stars[i].X1, stars[i].Y1, 
        stars[i].X2, stars[i].Y2, 
        stars[i].thickness, 
        stars[i].currentColor);
      }
    }
  }

  void step(int entities) {
    for(uint i = 0; i < stars.length(); i++) {
      stars[i].update();
    }
  }

  void draw(float subframe) {
    if(animate) {
      for(uint i = 0; i < stars.length(); i++) {
        stars[i].animate(g);
      }
    }
  }
}

class shootingStar {
  [position,mode:world,layer:0,y:Y1] float X1;
  [position,mode:world,layer:0,y:Y2] float X2;
  [text] uint fadeTime;
  [text] int sublayer;
  [text] float thickness;
  [text] float speed;
  [text] uint frequency;
  [text] bool showLines;

  // 1/60th of a second intervals
  [hidden] int fadeTimer;
  [hidden] int randomTimer;
  [hidden] int deltaFadeTime;
  [hidden] int deltaRandomTime;
  [hidden] int randomTimerStart;
  [hidden] float Y1;
  [hidden] float Y2;
  [hidden] uint currentColor;
  [hidden] bool faded;
  [hidden] bool timing;
  Timer randomTim;
  Timer fadeTim;
  float CurX1, CurY1, CurX2, CurY2;
  bool initialized;

  shootingStar() {
    X1 = Y1 = X2 = Y2 = CurX1 = CurY1 = CurX2 = CurY2 = 0;
    fadeTime = 0;
    fadeTimer = 0;
    randomTimer = 0;
    sublayer = 1;
    thickness = 100;
    currentColor = WHITE;
    faded = false;
    deltaRandomTime = 0;
    deltaFadeTime = 0;
    initialized = false;
    srand(timestamp_now());
    frequency = 1;
    speed = 10000;
  }

  void animate(scene@ g) {
    drawCurrentLine(g);
  }

  void reset() {
    resetXY();
    faded = false;
    currentColor = WHITE;
  }

  void resetXY() {
    if(X1 != X2) {
      Line path(X1, Y1, X2, Y2);
      CurX1 = X1;
      CurY1 = Y1;
      CurX2 = X1;
      CurY2 = Y1;
    }
  }
  
  void updateXY() {
    if(X1 != X2) {
      Line path(X1, Y1, X2, Y2);
      //puts("   x1 "+X1+"    x2 " +X2+"    y1 "+Y1+"    y2 "+Y2);
      //puts("Curx1 "+CurX1+" Curx2 " +CurX2+" Cury1 "+CurY1+" Cury2 "+CurY2);
      float test = sqrt(1+path.slope()*path.slope());
      //puts("speed: " +speed+" sqrt: "+test);
      int dir = X1 > X2 ? -1 : 1;
      CurX2 = CurX2 + (dir * speed/sqrt(1+path.slope()*path.slope()));
      CurY2 = path.getY(CurX2);
      //int temp = X1 > X2 ? -1 : 1;
      //puts("Curx1 "+CurX1+" Curx2 " +CurX2+" Cury1 "+CurY1+" Cury2 "+CurY2 + " dir "+temp);
      //puts("==================================================");
      
    }
  }

  void update() {
    if(!initialized) {
      reset();
      initialized = true;
      randomTim.start(rand() % frequency);
    }
    //Update cur coordinates
    //Update fade stuff
    if(randomTim.run()) {
      return;
    }

    if(starDone()) {
      fade();
    } else {
      updateXY();
    }
    if(faded && !randomTim.run() && starDone()) {
      int i = rand();
      randomTim.start(rand() % frequency);
      reset();
    }
  }

  bool starDone() {
    return max(CurX1, CurX2) > max(X1, X2) || min(CurX1,CurX2) < min(X1, X2);
  }

  void drawCurrentLine(scene@ g) {
    g.draw_line_world(0, sublayer, CurX1, CurY1, CurX2, CurY2, thickness, currentColor);
  }

  //requires 255 steps to fade
  void fade() {
    uint alpha = (currentColor & 0xFF000000) >> 24;
    if(alpha >= 255/fadeTime) {
      alpha -= 255/fadeTime;
    } else {
      alpha = 0;
    }
      
    currentColor &= 0x00FFFFFF;
    currentColor |= (alpha << 24);

    if(alpha <= 0) {
      faded = true;
      alpha = 0;
    }
  }
}

class Timer {
  bool isStarted;
  int dur;
  int deltaTime;
  int countdown;
  int one60th;

  Timer() {
    //1/60th of a second in microseconds
    one60th = 1000000;
    countdown = 0;
    isStarted = false;
  }

  void start(int duration) {
    if(isStarted) {
      return;
    }
    countdown = duration;
    isStarted = true;
    deltaTime = 0;
  }

  bool run() {
    if(!isStarted) {
      return false;
    }
    if(deltaTime == 0) {
      deltaTime = get_time_us();
    }
    int time = get_time_us();
    int output = time - deltaTime;
    if(time - deltaTime >= one60th) {
      countdown--;
      deltaTime = get_time_us();
    }

    if(countdown > 0) {
      return true;
    } else {
      stop();
      return false;
    }
  }

  int remaining() {
    return countdown;
  }

  void stop() {
    isStarted = false;
    countdown = 0;
    deltaTime = 0;
  }
  
}

class shootingStarTrigger : trigger_base {
  scene@ g;
  scripttrigger@ self;
  bool activated;
  bool active_this_frame;
  controllable@ trigger_entity;
  [text|tooltip:"Set true if this trigger should stop stars.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] bool stopTrigger;

  shootingStarTrigger() {
    @g = get_scene();
    stopTrigger = false;
  }

  void init(script@ s, scripttrigger@ self) {
      @this.self = @self;
      activated = false;
      active_this_frame = false;
  }
  
  void rising_edge(controllable@ e) {
      @trigger_entity = @e;
      notifyScript();
  }

  void falling_edge(controllable@ e) {
      @trigger_entity = null;
      //do stuff
  }

  void editor_draw(float sub_frame) {

  }

  void editor_step() {
    self.editor_colour_active(GREEN);
    self.editor_colour_inactive(GREEN);
    self.editor_colour_circle(GREEN);
  }

  void step() {
      if(activated) {
          if(not active_this_frame) {
              activated = false;
              falling_edge(@trigger_entity);
          }
          active_this_frame = false;
      }
  }
  
  void activate(controllable@ e) {
      if(e.player_index() == 0) {
          if(not activated) {
              rising_edge(@e);
              activated = true;
          }
          active_this_frame = true;
      }
  }

  void notifyScript() {
    if(stopTrigger) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    message@ msg = create_message();
    msg.set_int('start', 1);
    msg.set_string('triggerType',"shootingStar");
    broadcast_message('OnMyCustomEventName', msg);
  }

  void stop() {
    message@ msg = create_message();
    msg.set_int('stop', 1);
    msg.set_string('triggerType',"shootingStar");
    broadcast_message('OnMyCustomEventName', msg);
  }
}