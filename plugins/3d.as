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
const float fov = 90;
const float hitbox_half = 45;
const float block_width = 2000;
const float enemy_width = 1000;
const float enemy_scan_distance = 2000;
const int INT_MAX = 2147483647;

class script {
  [text] bool debugEnabled = true;
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
  bool looking = false;
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
    looking = dm.taunt_intent() == 1 ? !looking: looking;

    //Use taunt to control looking up/down
    if(looking && dm.y_intent() != 0) {
      facing_angle = dm.y_intent() * 30;
    } else {
      facing_angle = 0;
    }
    
    disableAllMovement(dm, looking);
    updateSeenEntities();
    doRaycast(dm);
  }

   void draw(float sub_frame) {
      drawLines();
   }

  void disableAllMovement(dustman@ dm, bool disable) {
    if(!disable) {
      return;
    }
    dm.x_intent(0);
    dm.y_intent(0);
    dm.jump_intent(0);
    dm.heavy_intent(0);
    dm.light_intent(0);
    dm.dash_intent(0);
  }

  void doRaycast(dustman@ dm) {
    //Empty drawnLines array
    drawnLines.resize(0);
    uint baseColor = WHITE;
    float r = 4000;
    uint color = BLUE;
    Line@ l; //the line to draw
    uint entityColor = PURPLE & 0x00926EAE | 0xCC000000;

    for(float i = 1; i < mapHeight; i++) {
      float yDrawValue = i- mapHeight/2;
      float theta = (i/mapHeight * fov - (fov/2) + facing_angle) * DEG2RAD;
      float targetX = pos.x + r*cos(theta) * facing;
      float targetY = pos.y + r*sin(theta);

      @ray = g.ray_cast_tiles(pos.x, pos.y,  targetX,  targetY, ray);

      //Pixel cooridnates of the raycast. If the raycast 
      float rx = ray.hit() ? ray.hit_x() : targetX;
      float ry = ray.hit() ? ray.hit_y() : targetY;
      float dist = abs(pos.x - rx);
      
      //Tile coordinates of the raycast
      int tx = ray.tile_x();
      int ty = ray.tile_y();

      //Check if this ray hit the same tile as the previous raycast
      bool sameAsPrevTile = lastTileX == int(tx) && lastTileY == int(ty);
      lastTileX = (tx);
      lastTileY = (ty);

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
          float sq = sqrt(dist);
          float x1 = -block_width/sq;
          float y1 = (i- mapHeight/2);
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
        //Draw FOV lines for debug view
        g.draw_line_world(19,19,l.x1, l.y1, l.x2, l.y2, 1, col);
      } else {
        //Draw screen lines in gameplay mode
        c.draw_line(l.x1*screenScaleX/2, l.y1*screenScaleY, l.x2*screenScaleX/2, l.y2*screenScaleY, count_lines*screenScaleY, col);
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
