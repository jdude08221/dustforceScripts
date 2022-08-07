// https://lodev.org/cgtutor/raycasting.html

#include "../jlib/math/Vec2Math.as"
#include "../jlib/const/ColorConsts.as"
#include "../lib/math/Vec2.cpp"
#include "../lib/math/math.cpp"
#include "../lib/math/Line.cpp"

const float tileSize = 48;
const float realScreen_H = 900;
const float realScreen_W = 1600;
const float map_height = 225;
const float map_width = 400;
const float halfmap_width = map_width / 2;
const float fov = 60;
const float hitbox_half = 45;
const float block_height = 60000;
const float enemy_height = 1000;
const float enemy_scan_distance = 2000;
const int INT_MAX = 2147483647;
const uint ENEMY_COLOR = PURPLE & 0x00926EAE | 0xCC000000;

const float speed = 15;

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
  float count_lines = map_width/fov;
  bool looking = false;
  float screenScaleX = realScreen_W / map_width;
  float screenScaleY = realScreen_H / map_height;

  uint lineDrawChecker = 0;
  uint frameCount = 0;

  int lastTileX = INT_MAX;
  int lastTileY = INT_MAX;

  bool clicked = false;

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
    
    if(player is null) {
      @player = controller_controllable(get_active_player());
      setupDMPhysics(player.as_dustman());
      return;
    }

    mouse_y = g.mouse_y_hud(get_active_player());
    mouse_x = g.mouse_x_hud(get_active_player());

    if(g.mouse_state(get_active_player()) & 4 == 4 && !clicked) {
      shoot(player.as_dustman());
      clicked = true;
    } else if(g.mouse_state(get_active_player()) & 4 != 4) {
      clicked = false;
    }

    if(debugEnabled) {
      for(uint i = 6; i < 21; i++) {
        g.layer_visible(i, true);
      }
    }

    dustman@ dm = player.as_dustman();
    move(dm);
    pos.x = dm.x();
    pos.y = dm.y()-80;

    

    facing = dm.attack_state() != 0 ? dm.attack_face() : dm.face();
    debugEnabled = dm.taunt_intent() == 1 ? !debugEnabled: debugEnabled;

    facing_angle = mouse_x/4 % 360;
    
    disableAllMovement(dm, looking);
    updateSeenEntities();
    doRaycast(dm);
    frameCount++;
  }

   void draw(float sub_frame) {
      drawLines();
      drawAimer();
      if(debugEnabled) {
        g.draw_line_world(19,19,pos.x, pos.y, pos.x + 500 * cos(facing_angle*DEG2RAD), pos.y + 500*sin(facing_angle*DEG2RAD), 1, ORANGE);
      }
   }

   void drawAimer() {
      //void draw_rectangle(float x1, float y1,
      //float x2, float y2, float rotation, uint colour);
      c.draw_rectangle(0, 0, 10, 10, 0, WHITE);
   }

  void shoot(dustman@ dm) {
    puts("BANG!");
  }
  void editor_step() {
    for(uint i = 6; i < 21; i++) {
      g.layer_visible(i, true);
    }
  }

  void setupDMPhysics(dustman@ dm) {
    if(@dm != null) {
      dm.fall_max(0);
      dm.fall_accel(0);
      dm.hover_accel(0);
    }
  }

  void move(dustman@ dm) {
    int forward = dm.y_intent();
    int sideways = dm.x_intent();

    float x = 0;
    float y = 0;

    if (forward == 0 && sideways != 0) {
      float theta = (facing_angle + (90 * sideways)) * DEG2RAD;
      x = speed * cos(theta);
      y = speed * sin(theta);
    } else if (forward != 0 && sideways != 0) {
      float theta = (facing_angle + (45 * sideways)) * DEG2RAD;
      x = -forward * speed * cos(theta);
      y = -forward * speed * sin(theta);
    } else if (forward != 0 && sideways == 0) {
      float theta = (facing_angle) * DEG2RAD;
      x = -forward * speed * cos(theta);
      y = -forward * speed * sin(theta);
    } 

    dm.x(dm.x()+x);
    dm.y(dm.y()+y);
    disableAllMovement(dm, true);
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

    //length of the raycasts in pixels
    float r = 4000;

    uint color = BLUE;
    Line@ l; //the line to draw
    uint entityColor = PURPLE & 0x00926EAE | 0xCC000000;
    
    //Do all the raycasts for each horizontal line drawn to the screen
    for(float i = 0; i < map_width; i++) {

      //Angle of the raycast. Used for polar coordinate calculation
      float theta = (i/map_width * fov - (fov/2) + facing_angle) * DEG2RAD;
      float targetX = pos.x + r*cos(theta);
      float targetY = pos.y + r*sin(theta);

      @ray = g.ray_cast_tiles(pos.x, pos.y,  targetX,  targetY, ray);

      //Pixel cooridnates of the raycast. If the raycast doesnt hit anything, just set its value to be the destination
      float rx = ray.hit() ? ray.hit_x() : targetX;
      float ry = ray.hit() ? ray.hit_y() : targetY;
      float dist = distance(pos.x, pos.y, rx, ry) * cos(theta - facing_angle*DEG2RAD);
      
      //g.draw_line_world(19,19, rx, ry, pos.x+dist, pos.y, 1, PURPLEMOUNTAINSMAJESTY);

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

          float y1 = -block_height/dist;
          float x1 = (i- halfmap_width);
          @l = Line(x1, -y1, x1, y1);
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
            dist = abs((pos.x) - ((r1x+r2x)/2));

            float sq = sqrt(dist);
            float x1 = -enemy_height/sq;
            float y1 = (i- halfmap_width);
            Line@ l;
            if(!debugEnabled) {
              @l = Line(x1, y1, -x1, y1);
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
        //Draw screen lines in gameplay mode)
        c.draw_line(l.x1*4, l.y1*4, l.x2*4, l.y2*4, 1*4, col);
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
