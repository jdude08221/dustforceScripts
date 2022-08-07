// https://lodev.org/cgtutor/raycasting.html

#include "../jlib/math/Vec2Math.as"
#include "../jlib/const/ColorConsts.as"
#include "../lib/math/Vec2.cpp"
#include "../lib/math/math.cpp"
#include "../lib/math/Line.cpp"

const float tileSize = 48;
const float realScreenW = 1600;
const float realScreenH = 900;
const float mapWidth = 533;
const float mapHeight = 300;
const float halfMapHeight = mapHeight / 2;
const float fov = 90;
const float hitbox_half = 45;
const float block_width = 25000;
const float enemy_width = 10000;
const float enemy_scan_distance = 2000;
const int INT_MAX = 2147483647;
const uint ENEMY_COLOR = PURPLE & 0x00926EAE | 0xCC000000;

enum LOOKING_ANGLE {
  MIDDLE = 0,
  DOWN = 1,
  UP = 2,
  SIZE = 3
}

class script {
  [text] bool debugEnabled = false;
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
  LOOKING_ANGLE lookAngle = LOOKING_ANGLE::MIDDLE;
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
    mouse_y = g.mouse_y_hud(0);
    
    if(player is null) {
      @player = controller_controllable(get_active_player());
      return;
    }

    if(debugEnabled) {
      for(uint i = 6; i < 21; i++) {
        g.layer_visible(i, true);
      }
    }

    dustman@ dm = player.as_dustman();
    pos.x = dm.x();
    pos.y = dm.y()-80;

    facing = dm.attack_state() != 0 ? dm.attack_face() : dm.face();

    //Use taunt to control looking up/down
    if(dm.taunt_intent() == 1) {
      cycleLookAngle();
    }

    facing_angle = getLookingAngle(lookAngle);

    updateSeenEntities();
    doRaycast(dm);
  }

  float getLookingAngle(LOOKING_ANGLE a) {
    switch (a) {
      case LOOKING_ANGLE::DOWN:
        return 30;
      case LOOKING_ANGLE::UP:
        return -30;
      case LOOKING_ANGLE::MIDDLE:
        return 0;
    }
    return 0;
  }

  void cycleLookAngle() {
    lookAngle = LOOKING_ANGLE(int(lookAngle + 1) % int(LOOKING_ANGLE::SIZE));
  }

   void draw(float sub_frame) {
      drawLines();
   }

  void editor_step() {
    for(uint i = 6; i < 21; i++) {
      g.layer_visible(i, true);
    }
  }

  void doRaycast(dustman@ dm) {
    //Empty drawnLines array
    drawnLines.resize(0);
    uint baseColor = WHITE;

    //length of the raycasts in pixels
    float r = 4000;

    uint color = BLUE;
    Line@ l; //the line to draw
    uint entityColor = PURPLE & 0x00926EAE | 0xCC000000;
    
    //Do all the raycasts for each horizontal line drawn to the screen
    for(float i = 1; i < mapHeight; i++) {
      float yDrawValue = i- halfMapHeight;

      //Angle of the raycast. Used for polar coordinate calculation
      float theta = (i/mapHeight * fov - (fov/2) + facing_angle) * DEG2RAD;
      float targetX = pos.x + r*cos(theta) * facing;
      float targetY = pos.y + r*sin(theta);
      @ray = g.ray_cast_tiles(pos.x, pos.y,  targetX,  targetY, ray);

      //Pixel cooridnates of the raycast. If the raycast doesnt hit anything, just set its value to be the destination
      float rx = ray.hit() ? ray.hit_x() : targetX;
      float ry = ray.hit() ? ray.hit_y() : targetY;

      float dist = distance(pos.x, pos.y, rx, ry) * cos(theta - facing_angle*DEG2RAD);
      //Tile coordinates of the raycast
      int tx = ray.tile_x();
      int ty = ray.tile_y();

      //Check if this ray hit the same tile as the previous raycast
      bool sameAsPrevTile = lastTileX == tx && lastTileY == ty;
      lastTileX = tx;
      lastTileY = ty;

      //Get tile hit by raycast. If its the same as the previously hit tile, 
      //just reuse the tile from last iteration
      if(!sameAsPrevTile) {
        @tf = g.get_tile_filth(tx, ty);
        @ti = g.get_tile(tx, ty);
      }

      //Check each tile side for spikes/dust. Depending on the tile's
      //filth/spikyness/side, pick the correct color for it
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
        //Add full alpha to the tile
        baseColor |= RGBALPHA;
        color = baseColor;
        
        Line@ l;

        if(debugEnabled) {
          @l = Line(pos.x, pos.y, rx, ry);
        } else if(ray.hit()){
          float x1 = -block_width/dist;
          float y1 = (i- halfMapHeight);
          @l = Line(x1, y1, -x1, y1);
        }

        if(l != null) {
          coloredLine @colLine = coloredLine(l, color);
          drawnLines.insertLast(colLine);
        }

        for(uint j = 0; j < seenEntities.size(); j++) {
          //If the raycast line intersects the enemy hitbox, draw a line for it
          entity@ e = seenEntities[j];
          rectangle@ rect = e.base_rectangle();

          //Get the corner coordinates of the enemy's rectangle object
          float r1x = e.x() + rect.left();
          float r1y = e.y() + rect.top();
          float r2x = e.x() + rect.right();
          float r2y = e.y() + rect.bottom();

          //These three values are unused
          float x, y, t;

          //check if the current raycast intersects the entity
          if(line_rectangle_intersection(pos.x, pos.y, targetX, targetY,
          r1x, r1y, r2x, r2y, x, y, t)) {
            //Get distance from the enemy to the camera plane

            dist = distance(pos.x, pos.y, (r1x+r2x)/2, (r1y+r2y)/2) * cos(theta - facing_angle*DEG2RAD);
            float x1 = (enemy_width/2)/dist;
            float y1 = (i- halfMapHeight);
            Line@ l;
            if(!debugEnabled) {
              @l = Line(-x1, y1, x1, y1);
            } else {
              @l = Line(pos.x, pos.y, rx, ry);
            }
            if(@l != null) {
              coloredLine @colLine = coloredLine(l,  ENEMY_COLOR);
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
        //Draw FOV lines for debug view
        g.draw_line_world(19,19,l.x1, l.y1, l.x2, l.y2, 1, col);
      } else {
        //Draw screen lines in gameplay mode
        c.draw_line(l.x1*3, l.y1*3, l.x2*3, l.y2*3, 3, col);
      }
    }

  }

  void updateSeenEntities() {
    array<entity@> ret;
    dustman@ dm = player.as_dustman();
    seenEntities.resize(0);
    float left = facing == -1 ? dm.x() - enemy_scan_distance : dm.x();
    float right = facing == 1 ? dm.x() + enemy_scan_distance : dm.x();
    int num = g.get_entity_collision(
      dm.y()-enemy_scan_distance, 
      dm.y()+enemy_scan_distance, 
      left,
      right, 7);

    for(int i = 0; i < num; i++) {
      entity@ e = g.get_entity_collision_index(i);

      //Ignore all dustman entities
      if(e.as_dustman() != null) {
        continue;
      }

      @ray = g.ray_cast_tiles(dm.x(),dm.y()-80,e.x(),e.y());
       
      //Entity not behind wall
      if(!ray.hit()) {
        //Debug mode: draw lines to seen enemies
        if(debugEnabled) {
          g.draw_line_world(19,19,dm.x(), dm.y()-80, e.x(), e.y(), 1, WHITE);
        }

        seenEntities.insertLast(e);
      }
    }
  }

  bool isDustblock(tileinfo@ ti) {
    //Check the various dustblock sprite sets
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
