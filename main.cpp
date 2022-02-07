#include "../myScripts/lib/math/math.cpp"
#include"../myScripts/jlib/const/ColorConsts.as"

class script {
  dustman@ ghost_dm;
  textfield@ t;
  float textX, textY;
  float distance_ghost = 0;
  float distance_ghost_prev = 0;
  array<int> datapoints(0);
  script() {
    textX = 0;
    textY = 0;
  }

  void step(int) {
    if(!is_replay()) {
      return;
    }
    
    entity@ p1 = controller_entity(0);
    
    if(@ghost_dm != null && @p1 != null) {
      distance_ghost_prev = distance_ghost;
      distance_ghost = distance(ghost_dm.x(), ghost_dm.y(), p1.x(), p1.y());
      //datapoints.insertLast(distance_ghost);
      t.text("Current Distance:" + distance_ghost);
      uint colour = distance_ghost > distance_ghost_prev ? RED : GREEN;
      t.colour(colour);
    }
  }

  void on_level_start() {
    @t = create_textfield();
    t.set_font("envy_bold", 20);
    t.colour(0xFFFFFFFF);
    t.text("TEST:=============");
  }

  void on_level_end() {
    //puts(datapoints.size()+"");
  }

  void draw(float) {
    entity@ p1 = controller_entity(0);
    t.draw_hud(22, 20, 40, 400, 1, 1, 0);
  }

  void entity_on_add(entity@ e) {
    /* Called when an entity is added to the scene. */
    if(@e.as_controllable() != null && @e.as_controllable().as_dustman() != null) {
      if(@controller_entity(0) != null && !controller_entity(0).is_same(e)) {
        @ghost_dm =  e.as_controllable().as_dustman();
      }
    }
  }
}