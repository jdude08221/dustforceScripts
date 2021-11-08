#include "jlib/const/ColorConsts.as"
#include "../lib/math/Line.cpp"
#include "../lib/drawing/Sprite.cpp"
const string EMBED_lakitu= "lakitu.png";

class script {
  [text] int move_speed;
  scene@ g;
  camera@ c;
  sprites@ spr;
  Sprite@ s;
  dustman@ dm;
  float buffer = 10;
  float spr_x, spr_y;
  int scale_x;
  int scale_y;
  bool moving;
  bool setup = false;
  script() {
    @g = get_scene();
    @spr = create_sprites();
    @s = Sprite("script", "lakitu");
    scale_x = 1;
    scale_y = 1;
    moving = false;
    move_speed = 0;
  }

   void build_sprites(message@ msg) {
      msg.set_string("lakitu","lakitu");
   }

  void on_level_start() {
    @c = get_camera(0);
    spr.add_sprite_set("script");
  }

  void moveLaki() {

  }

  void step(int subframe) {
    if(@controller_entity(0) != null) {
      @dm = controller_entity(0).as_dustman();
    }

    spr.add_sprite_set("script");


    
    if(@dm != null) {
      if(!setup) {
        spr_y = dm.y() - 200;
        spr_x = dm.x() + 500;
        setup = true;
      }

      Line l = Line(dm.x(), dm.y(), c.x(), c.y());

      if(l.length > 20) {
        int temp_x = scale_x;
        int temp_y = scale_y;
        scale_x = dm.x() < spr_x ? -1 : 1;
        scale_y = dm.y() < spr_y ? -1 : 1;
        move();
      }
    }

    if(moving) {
      move();
    }
  }

  void draw(float) {
    s.set("script", "lakitu");
    s.draw(20, 1, 0, 1, spr_x, spr_y, 0, scale_x, 1, 0xFFFFFFFF);
  }

  void move() {
    if(@dm != null && @c != null) {
      puts("x "+spr_x+" y "+spr_y+" dmx "+dm.x()+" dmy "+dm.y());
      Line l = Line(spr_x, spr_y, dm.x() + 500, dm.y() - 200);
      puts(l.length + "");
      if(l.length > 600) {
        puts(""+(spr_y + (move_speed * 2 * scale_y)));
        spr_x = abs(spr_x + (move_speed * scale_x) - dm.x()) > 500 ? spr_x + (move_speed * scale_x) : spr_x;
        spr_y = abs(spr_y + (move_speed * scale_y) - dm.y()) > 1 ? spr_y + (move_speed * scale_y) : spr_y;
      } else if(l.length > 1000){
        puts("move");

        spr_x = abs(spr_x + (move_speed * 2 * scale_x) - dm.x()) > 500 ? spr_x + (move_speed * scale_x) : spr_x;
        spr_y = abs(spr_y + (move_speed * 2 * scale_y) - dm.y()) > 1 ? spr_y + (move_speed * 20 * scale_y) : spr_y;
      }
      
    } else {
      moving = false;
    }
  }
}