// https://lodev.org/cgtutor/raycasting.html

#include "../jlib/math/Vec2Math.as"
#include "../jlib/const/ColorConsts.as"
#include "../lib/math/Vec2.cpp"
#include "../lib/math/math.cpp"
#include "../lib/math/Line.cpp"

const float tileSize = 48;
const float realScreenW = 1600;
const float realScreenH = 900;
const float mapWidth = 400;
const float mapHeight = 250;
const float fov = 90;
const float hitbox_half = 45;
const float block_width = 2000;
const float enemy_width = 1000;
const float enemy_scan_distance = 2000;
const int INT_MAX = 2147483647;
class script {
  [text] bool debugEnabled = true;
  [hidden] float Y1;
  [position,mode:hud,layer:19,y:Y1] float X1;

  scene@ g;
  canvas@ c;
  Vec2@ pos;
  raycast@ ray;
  controllable@ player = null;

  //Vars to store previous tile's attributes
  tilefilth@ tf;
  tileinfo@ ti;
  array<entity@> seenEntities(0);
  array<coloredLine@> drawnLines(0);
  int facing = 1;
  uint lastColor = 0;
  uint raycastDebugCount = 0;
  float facing_angle = 0;
  float mouse_x = 0;
  float mouse_y = 0;
  float count_lines = mapHeight/fov;
  
  float screenScaleX = realScreenW / mapWidth;
  float screenScaleY = realScreenH / mapHeight;

  int lastTileX = INT_MAX;
  int lastTileY = INT_MAX;
  script() {
    @g = get_scene();
    @c = create_canvas(true, 0, 0);
  }
  

  void checkpoint_load() {
    @player = null;
  }


  void on_level_start() {
    @pos = Vec2(0,0);
    if(!debugEnabled) {
      for(uint i = 6; i < 21; i++) {
        g.layer_visible(i, false);
      }
    }
  }

  
  void step(int) {

  /* Returns the y coordinate of the mouse in the hud coordinate space. If scale
   * is set to true will auto scale the coordinates to simulate a 1600-900
   * screen size. Will range between -height/2 and height/2.
   */
    mouse_x = g.mouse_x_hud(0);
    mouse_y = g.mouse_y_hud(0);
    facing_angle = (mouse_y/900) * (60);
    if(player is null) {
      @player = controller_controllable(0);
      return;
    }
    dustman@ dm = player.as_dustman();

    pos.x = dm.x();
    pos.y = dm.y()-80;
    facing = dm.attack_state() != 0 ? dm.attack_face() : dm.face();
    updateSeenEntities();
    if(debugEnabled) {
      for(uint i = 6; i < 21; i++) {
        g.layer_visible(i, true);
      }
    }
    doRaycast();
  }

   void draw(float sub_frame) {
      drawLines();
   }

  void doRaycast() {
    drawnLines.resize(0);
    for(float i = 0; i < mapHeight; i++) {
      if(player == null)
        return;

      dustman@ dm = player.as_dustman();
      float r = 4000;
      uint color = BLUE;
      //-450 to 450
      float theta = i == 0 ? 0 : (i/mapHeight * fov - (fov/2) + facing_angle)*DEG2RAD;

      float targetX = pos.x + r*cos(theta) * facing;
      float targetY = pos.y + r*sin(theta);

      @ray = g.ray_cast_tiles(pos.x, pos.y,  targetX,  targetY, ray);
      if(!ray.hit() && !debugEnabled) {
        continue;
      }
      float rx = ray.hit() ? ray.hit_x() : targetX;
      float ry = ray.hit() ? ray.hit_y() : targetY;
      float dist = abs(pos.x - rx);
      
      int tx = rx / 48.0;
      int ty = ry / 48.0;
      if(facing == -1)
        tx --;
      //  void draw_rectangle_world(uint layer, uint sub_layer, float x1, float y1,
      //float x2, float y2, float rotation, uint colour);
      //g.draw_rectangle_world(20,20, tx*48, ty*48, tx*48+48, ty*48+48, 0, WHITE);
      g.draw_rectangle_world(20,20, rx-5,ry-5, rx+5, ry+5, 0, RED);
      bool sameAsPrevTile = lastTileX == int(tx) && lastTileY == int(ty);
      lastTileX = (tx);
      lastTileY = (ty);
      
      //Get tile hit by raycast
      if(!sameAsPrevTile) {
        @tf = g.get_tile_filth(tx, ty);
        @ti = g.get_tile(tx, ty);
      }
      uint baseColor = WHITE;
      /* Returns 0-3 indicating the side of the edge hit from
      * top, bottom, left, right in that order. */

      switch(ray.tile_side()) {
        case 0://top
          baseColor = getBaseColor(ti, tf.top(), 1);
          break;
        case 1://bottom
          baseColor = getBaseColor(ti, tf.bottom(), 4);
          break;
        case 2://left
          baseColor = getBaseColor(ti, tf.left(), 2);
          break;
        case 3://right
          baseColor = getBaseColor(ti, tf.right(), 2);
          break;
        default:
          color = baseColor;
          break;

      }
        baseColor |= RGBALPHA;
        color = baseColor;

        if(debugEnabled) {
          Line@ l = Line(pos.x, pos.y, rx, ry);
          coloredLine @colLine = coloredLine(l, color);
          drawnLines.insertLast(colLine);
        } else {
          float sq = sqrt(dist);
          float x1 = -block_width/sq;
          float y1 = (i- mapHeight/2);

          Line@ l = Line(x1, y1, -x1, y1);
          coloredLine @colLine = coloredLine(l, color);
          drawnLines.insertLast(colLine);
        }


        for(uint j = 0; j < seenEntities.size(); j++) {
          //If the raycast line intersects the enemy hitbox, draw a line for it
          entity@ e = seenEntities[j];
          rectangle@ rect = e.base_rectangle();

          float r1x = e.x() + rect.left();
          float r1y = e.y() + rect.top();
          float r2x = e.x() + rect.right();
          float r2y = e.y() + rect.bottom();

          float x, y, t;
          //check if the current raycast intersects the entity
          if(line_rectangle_intersection(pos.x, pos.y, targetX, targetY,
          r1x, r1y, r2x, r2y, x, y, t)) {
            dist = abs((pos.x) - ((r1x+r2x)/2));
            float sq = sqrt(dist);
            float x1 = -enemy_width/sq;
            float y1 = (i- mapHeight/2);
            if(!debugEnabled) {
              Line@ l = Line(x1, y1, -x1, y1);
              coloredLine @colLine = coloredLine(l, PURPLE & 0x00926EAE | 0xCC000000);
              drawnLines.insertLast(colLine);
            } else {
              Line@ l = Line(pos.x, pos.y, rx, ry);
              coloredLine @colLine = coloredLine(l,  PURPLE & 0x00926EAE | 0xCC000000);
              drawnLines.insertLast(colLine);
            }
          }
        }
    }
  }

  void drawLines() {
    for(uint i = 0; i < drawnLines.size(); i++){
      Line l = drawnLines[i].l;
      uint col = drawnLines[i].color;
      if(debugEnabled) {
        g.draw_line_world(19,19,l.x1, l.y1, l.x2, l.y2, 1, col);
      } else {
        c.draw_line(l.x1*screenScaleX/2, l.y1*screenScaleY, l.x2*screenScaleX/2, l.y2*screenScaleY, count_lines*screenScaleY, col);
      }
    }
  }

  void updateSeenEntities() {
    dustman@ dm = player.as_dustman();
    seenEntities.resize(0);
    float left = facing == -1 ? dm.x() - enemy_scan_distance : dm.x();
    float right = facing == 1 ? dm.x() + enemy_scan_distance : dm.x();
    int num = g.get_entity_collision(
      dm.y()-enemy_scan_distance, 
      dm.y()+enemy_scan_distance, 
      left,
      right, 7);

    array<entity@> ret;
    for(int i = 0; i < num; i++) {
      entity@ e = g.get_entity_collision_index(i);

      //Ignore all dustman entities
      if(e.as_dustman() != null) {
        continue;
      }

      @ray = g.ray_cast_tiles(dm.x(),dm.y(),e.x(),e.y());
      //Entity not behind wall
      if(!ray.hit()) {
        seenEntities.insertLast(e);
      }
    }
  }

  void editor_step() {
    for(uint i = 6; i < 21; i++) {
      g.layer_visible(i, true);
    }
  }

  bool isDustblock(tileinfo@ ti) {
    switch (ti.sprite_set()) {
      case 1:
        return ti.sprite_tile() == 21;
      case 2:
        return ti.sprite_tile() == 13;
      case 3:
        return ti.sprite_tile() == 6;
      case 4:
        return ti.sprite_tile() == 9;
      case 5:
        return ti.sprite_tile() == 2;
      default:
        return false;
    }
    return false;
  }

  uint getBaseColor(tileinfo@ ti, uint collisionType, uint divisor) {
    uint baseColor = WHITE;
    if(isDustblock(ti)) {
      baseColor = ORANGE & 0x00FFFFFF;
      return baseColor;
    }

    if(collisionType == 0) {
      baseColor = RGBBLUE;
      baseColor /= divisor;
    } else if( collisionType > 0 && collisionType < 6) {
      baseColor = RGBGREEN;
    } else {
      baseColor = RGBRED;
    }
    return baseColor;
  }
}

class coloredLine {
  Line@ l;
  uint color;
  coloredLine(Line@ l_, uint color_) {
    @l = l_;
    color = color_;
  }
}
