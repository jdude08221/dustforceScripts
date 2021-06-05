const string EMBED_out1 = "safeout2/spikey.png"; 

class script : callback_base{
  sprites@ spr;
  scene@ g;
  [text] bool showSprite;
  [slider,min:0,max:1] float scale;
  [position,mode:world,layer:19,y:Y1] float X1;

  [hidden] float Y1;
  [hidden] float volume;
  script() {
    @g = get_scene();
    X1 = 0;
    scale = 1;
    Y1 = 0;
    @spr = create_sprites();
  }

  void build_sprites(message@ msg) {    
      msg.set_string("out1","out1"); 
  }


  void on_level_start() {
    spr.add_sprite_set("script");  
  }

  void step(int) {
  }

  void editor_draw(float subframe) {
    if(showSprite) {
      spr.draw_world(20, 1, "out1", 0, 1, X1, Y1, 0, scale, scale, 0xFFFFFFFF);
    }
  }

  void editor_step() {
    spr.add_sprite_set("script");  
  }

  void draw(float subframe) {
    spr.draw_world(20, 1, "out1", 0, 1, X1, Y1, 0, scale, scale, 0xFFFFFFFF);
  }
}