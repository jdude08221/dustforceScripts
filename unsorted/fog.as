#include '../jlib/drawing/spriteConfig.as'
const string EMBED_fog = "fog.png";
const string EMBED_fog2 = "fog2.png";
class script {
  [text] bool showSprite;
  [text] bool animateSprite;
  [text] array<SpriteConfig> fog1;
  [text] array<SpriteConfig> fog2;
  sprites@ spr;
  scene@ g;
  uint draw_frame = 0;
  uint physics_frame = 0;


  script() {
     @spr = create_sprites();
     @g = get_scene();
  }
  
  void init() {
    for(uint i = 0; i < fog1.size(); i++) {
      fog1[i].init("fog", spr);
    }

    for(uint i = 0; i < fog2.size(); i++) {
      fog2[i].init("fog2", spr);
    }
  }

  void on_level_start() {
    spr.add_sprite_set("script");
    init();
  }

  void build_sprites(message@ msg) {    
    msg.set_string("fog","fog");
    msg.set_string("fog2","fog2");
  }

  void step(int entities) {
    if(g.get_script_fx_level() != 3) return;
      for(uint i = 0; i < fog1.size(); i++) {
        fog1[i].update();
      }
      for(uint i = 0; i < fog2.size(); i++) {
        fog2[i].update();
      }
  }

  void draw(float sub_frame) {
    if(g.get_script_fx_level() != 3) return;
    for(uint i = 0; i < fog1.size(); i++) {
      fog1[i].draw();
    }
    for(uint i = 0; i < fog2.size(); i++) {
      fog2[i].draw();
    }
  }

  void editor_step() {
    spr.add_sprite_set("script");
    if(animateSprite) {
      for(uint i = 0; i < fog1.size(); i++) {
        fog1[i].update();
      }
      for(uint i = 0; i < fog2.size(); i++) {
        fog2[i].update();
      }
    }
  }

  void editor_var_changed(var_info@ info) {
    init();
  }

  void editor_draw(float sub_frame) {
    if(showSprite) {
      for(uint i = 0; i < fog1.size(); i++) {
        fog1[i].draw();
      }
      for(uint i = 0; i < fog2.size(); i++) {
        fog2[i].draw();
      }
    }
  }

  void on_editor_start() {
    init();
  }
}

