// https://lodev.org/cgtutor/raycasting.html

#include "../jlib/math/Vec2Math.as"
#include "../jlib/const/ColorConsts.as"
#include "../lib/math/Vec2.cpp"
#include "../lib/math/math.cpp"

const float tileSize = 48;
const float mapWidth = 1600;
const float mapHeight = 900;
const float fov = 90;
const float hitbox_half = 45;
const float block_width = 2000;
const float enemy_width = 1000;
const float enemy_scan_distance = 2000;

class script {
  [text] bool debugEnabled = false;
  [hidden] float Y1;
  [position,mode:hud,layer:19,y:Y1] float X1;

  scene@ g;
  canvas@ c;
  Vec2@ pos;
  raycast@ ray;
  controllable@ player = null;
  array<entity@> seenEntities(0);
  int facing = 1;
  uint lastColor = 0;
  uint raycastDebugCount = 0;
  script() {
    @g = get_scene();
    @c = create_canvas(true, 0, 0);
  }
  

  void checkpoint_load() {
    @player = null;
  }


  void on_level_start() {
    @pos = Vec2(0,0);
  }

  
  void step(int) {
    if(player is null) {
      @player = controller_controllable(0);
      return;
    }
    dustman@ dm = player.as_dustman();

    pos.x = dm.x();
    pos.y = dm.y()-80;
    facing = dm.attack_state() != 0 ? dm.attack_face() : dm.face();
    updateSeenEntities();
  }

   void draw(float sub_frame) {
      c.draw_rectangle(-mapWidth/2, -mapHeight/2, mapWidth/2, mapHeight/2, 0, WHITE);
      doRaycast();
   }

   void editor_draw(float subframe) {
      if(debugEnabled) {
        debug_draw();
      }
   }



  void doRaycast() {
    for(float i = 0; i < mapHeight; i++) {
      dustman@ dm = player.as_dustman();
          float r = 4000;
          //float theta = (i-fov/2)*DEG2RAD;
          float theta = i == 0 ? 0 : (i/mapHeight * fov - fov/3)*DEG2RAD;
          float targetX = pos.x + r*cos(theta) * facing;
          float targetY = pos.y + r*sin(theta);
          @ray = g.ray_cast_tiles(pos.x, pos.y,  targetX,  targetY);

          float rx = ray.hit() ? ray.hit_x() : targetX;
          float ry = ray.hit() ? ray.hit_y() : targetY;

          float dist = abs(pos.x - rx);
          
          g.draw_line_world(18,20, pos.x, pos.y, rx, ry, 1, RED);
          uint color = BLUE;



         /* Each tile filth value indicates if and what type of filth or spikes are
          * present on a given face of a tile.  These values should be:
          *
          * 0: no filth/spikes
          * 1-5: dust, leaves, trash, slime, virtual filth
          * 9-13: mansion spikes, forest spikes, cones, wires, virtual spikes
          */

          //Get tile hit by raycast
          tilefilth@ tf = g.get_tile_filth(rx/48, ry/48);
          uint baseColor = WHITE;
          /* Returns 0-3 indicating the side of the edge hit from
          * top, bottom, left, right in that order. */
          switch(ray.tile_side()) {
            case 0://top
              baseColor = getBaseColor(tf.top(), 1);
              break;
            case 1://bottom
              baseColor = getBaseColor(tf.bottom(), 4);
              break;
            case 2://left
              baseColor = getBaseColor(tf.left(), 2);
              break;
            case 3://right
              baseColor = getBaseColor(tf.right(), 2);
              break;
            default:
              color = baseColor;
              break;
          }

          baseColor |= RGBALPHA;
          color = baseColor;
        
            c.draw_line(
            -block_width/sqrt(dist), 
            (i- mapHeight/2), 
            block_width/sqrt(dist), 
            (i- mapHeight/2), 
            mapHeight/fov, 
            color);


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
              c.draw_line(
              -enemy_width/sqrt(dist), 
              (i- mapHeight/2), 
              enemy_width/sqrt(dist), 
              (i- mapHeight/2), 
              mapHeight/fov, 
              PURPLE);
            }
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



  uint getBaseColor(uint collisionType, uint divisor) {
    uint baseColor = WHITE;
    if(collisionType == 0) {
      baseColor = RGBBLUE;
      baseColor /= divisor;
    } else if( collisionType > 0 && collisionType < 6) {
      baseColor = RGBGREEN;
    } else {
      baseColor = RGBRED;
      baseColor /= divisor;
    }

    return baseColor;
  }

   void debug_draw() {
    c.draw_rectangle(0, 0, mapWidth, mapHeight, 0, WHITE);
    c.draw_rectangle(X1, Y1, X1+10, Y1+10, 0, GREEN);
   }
}

