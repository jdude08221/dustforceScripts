const int NUM_FRAMES = 11; 
const string EMBED_out0 = "frames/out0.png";
const string EMBED_out1 = "frames/out1.png";
const string EMBED_out2 = "frames/out2.png";
const string EMBED_out3 = "frames/out3.png";
const string EMBED_out4 = "frames/out4.png";
const string EMBED_out5 = "frames/out5.png";
const string EMBED_out6 = "frames/out6.png";
const string EMBED_out7 = "frames/out7.png";
const string EMBED_out8 = "frames/out8.png";
const string EMBED_out9 = "frames/out9.png";
const string EMBED_out10 = "frames/out10.png";
const string EMBED_out11 = "frames/out11.png";
class script : callback_base{
  int frame_count;
  int draw_frame_count;
  int curSpriteIndex;
  sprites@ spr;
  scene@ g;
  [text] int layer;
  [text] int sublayer;
  [slider, min:.1, max:10] float scale;
  [text] bool showSprite;
 
  [position,mode:world,layer:19,y:Y1] float X1;

  [hidden] float Y1;
 
  
  array<string>framesGlobal(NUM_FRAMES);
  script() {
    @g = get_scene();
    X1 = 0;
    Y1 = 0;
    layer = 20;
    sublayer = 19;
    scale = 1;
    frame_count = 0;
    draw_frame_count = 0;
    curSpriteIndex = 0;
    @spr = create_sprites();
    framesGlobal[0] = "out1";
  }

  void build_sprites(message@ msg) {    
    for(int i = 1; i <= NUM_FRAMES; i++) {
      msg.set_string("out"+i,"out"+i); 
    }
  }

  void on_level_start() {
    //Populate names of frames into global frame array
    for(int i = 1; i <= NUM_FRAMES; i++) {
      framesGlobal[i-1] = "out" + i;
    }

    spr.add_sprite_set("script");  
   
  }

  void step(int) {
    //Only advance animation frame every 6 game ticks
    if(frame_count%5 == 0) {
      curSpriteIndex++;
    }

    frame_count++;

  }

  void editor_draw(float subframe) {
    if(showSprite) {
      spr.draw_world(layer, sublayer, framesGlobal[0], 0, 1, X1, Y1, 0, scale, scale, 0xFFFFFFFF);
    }
  }

  void editor_step() {
    spr.add_sprite_set("script");  
  }

  void draw(float subframe) {    
    spr.draw_world(layer, sublayer, framesGlobal[curSpriteIndex % NUM_FRAMES], 0, 1, X1, Y1, 0, scale, scale, 0xFFFFFFFF);
    draw_frame_count++;
  }
}