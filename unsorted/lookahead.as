#include "../lib/drawing/Sprite.cpp"
#include "../lib/props/common.cpp"

class script{
  scene@ g;
  camera@ c;
  dustman@ dm;
  uint frames = 0;
  bool camera_toggle = false;

  bool is_dustkid = false;

  Sprite spr1;
  [text] int stretch;
  [text] bool show_telescope = true;
  [hidden] string sprSet, sprName;
  float telescope_x = 0;
  float telescope_y = 0;

  script() {

  }

  void on_level_start() {
    @c = get_active_camera();
    c.script_camera(true);
  }

  void build_sprites(message@ msg) {
      msg.set_string("spr1","spr1");
  }

  void draw(float) {
    if(show_telescope && camera_toggle) {
      sprite_from_prop(1, 12, 2, sprSet, sprName);
      spr1.set(sprSet, sprName);
      float scale_y = is_dustkid ? .80f : 1.3f;
      spr1.draw(18, 9, 0, 0,
      telescope_x, telescope_y, //x,y
       0, 1, scale_y, 0xffffffff);
    }
  }

  void step(int) {
    if(@controller_entity(0) != null) {
      @dm = controller_entity(0).as_dustman();
    } else {
      return;
    }

    is_dustkid = dm.character() == "dustkid" || dm.character() == "v_dustkid";

    if(dm.ground()) {
      camera_toggle = dm.taunt_intent() == 1 ? !camera_toggle : camera_toggle;
    }
    
    @c = get_active_camera();
    frames++;

    if(!camera_toggle) {
      c.script_camera(false);
    }
    
    if(@dm != null && 
       dm.ground() == true &&
       camera_toggle &&
       @c != null) {
        c.x(c.x() + (stretch*dm.x_intent()));
        c.y(c.y() + (stretch*dm.y_intent()));
        telescope_x = dm.x() + get_x_offset(dm);
        telescope_y = dm.y() + get_y_offset(dm);
        dm.x_intent(0);
        dm.y_intent(0);
        dm.jump_intent(0);
        dm.heavy_intent(0);
        dm.light_intent(0);
        dm.dash_intent(0);
    }
  }

  float get_y_offset(dustman @dm) {
    //dustman, dustgirl, dustkid, dustworth
    if(dm.character() == "dustman" || dm.character() == "v_dustman") {
      return -73;
    }
    
    else if(dm.character() == "dustgirl" || dm.character() == "v_dustgirl") {
      return -74;
    }

    else if(dm.character() == "dustkid" || dm.character() == "v_dustkid") {
      return -50;
    }

    else if (dm.character() == "dustworth" || dm.character() == "v_dustworth") {
      return -70;
    }

    else {
      //who knows just return dustman value
      return -70;
    }
  }

  float get_x_offset(dustman @dm) {
    //dustman, dustgirl, dustkid, dustworth
    if(dm.character() == "dustman" || dm.character() == "v_dustman") {
      return 54;
    }
    
    else if(dm.character() == "dustgirl" || dm.character() == "v_dustgirl") {
      return 48;
    }

    else if(dm.character() == "dustkid" || dm.character() == "v_dustkid") {
      return 63;
    }

    else if (dm.character() == "dustworth" || dm.character() == "v_dustworth") {
      return 59;
    }

    else {
      //who knows just return dustman value
      return 48;
    }
  }
}