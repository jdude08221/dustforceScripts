#include "../myScripts/lib/math/math.cpp"
#include "../myScripts/jlib/const/ColorConsts.as"
#include "../myScripts/jlib/math/Vec3.as"
class script {
  dustman@ ghost_dm;
  textfield@ t;
  scene@ g;
  uint frames = 0;
  float textX, textY;
  float distance_ghost = 0;
  float distance_ghost_prev = 0;
  array<Datapoint@> datapoints(0);

  script() {
    @g = get_scene();
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
      Vec3@ v = Vec3(p1.x(), p1.y());
      uint color = WHITE;
      if(distance_ghost > distance_ghost_prev) {
        color = RED;
      } else if (distance_ghost == distance_ghost_prev) {
        color = WHITE;
      } else {
        color = GREEN;
      }
      Datapoint@ d = Datapoint(v, color);
      if(datapoints.size() > 1500) {
        datapoints.removeAt(0);
      }
      datapoints.insertLast(d);
      t.text("Current Distance:" + distance_ghost);
      t.colour(color);
    }
    frames++;
  }

  void on_level_start() {
    @t = create_textfield();
    t.set_font("envy_bold", 20);
    t.colour(0xFFFFFFFF);
    t.text("DISTANCE:=============");
  }

  void on_level_end() {
  }

  void draw(float) {
    entity@ p1 = controller_entity(0);
    t.draw_hud(22, 20, 40, 400, 1, 1, 0);
    for(uint i = 0; i+1 < datapoints.size(); i++) {
      g.draw_line_world(20, 19, 
      datapoints[i].point.x, 
      datapoints[i].point.y, 
      datapoints[i+1].point.x, 
      datapoints[i+1].point.y, 
      10, 
      datapoints[i+1].color);
    }
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

class Datapoint {
  uint color;
  Vec3@ point;

  Datapoint(Vec3@ v, uint c) {
    color = c;
    @point = v;
  }
}