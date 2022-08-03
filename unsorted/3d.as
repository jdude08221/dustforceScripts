// https://lodev.org/cgtutor/raycasting.html

#include "../jlib/math/Vec2Math.as"
#include "../jlib/const/ColorConsts.as"
#include "../lib/math/Vec2.cpp"
#include "../lib/math/math.cpp"

const float tileSize = 48;
const float mapWidth = 500;
const float mapHeight = 500;
const float castLen = 528;
const float fov = 100;
const float hitbox_half = 45;
const float block_width = 1000;
class script {
  [text] bool debugEnabled = false;
  [hidden] float Y1;
  [position,mode:hud,layer:19,y:Y1] float X1;

  scene@ g;
  canvas@ c;
  Vec2@ pos;
  raycast@ ray;
  controllable@ player = null;
  int facing = 1;

  script() {
    @g = get_scene();
    @c = create_canvas(false, 19, 19);
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
    facing = dm.face();
  }

   void draw(float sub_frame) {
      c.draw_rectangle(0, 0, mapWidth, mapHeight, 0, WHITE);

      doRaycast();
   }

   void editor_draw(float subframe) {
      if(debugEnabled) {
        debug_draw();
      }
   }

  void doRaycast() {
    for(float i = 0; i <= fov; i++) {

        /*raycast@ ray_cast_tiles(
          float x1, float y1, float x2, float y2,
          raycast@ result);*/
          @ray = g.ray_cast_tiles(pos.x, pos.y, 
          pos.x + mapHeight * tileSize * cos((i-fov/2)*DEG2RAD) * facing, 
          pos.y + mapHeight * tileSize * sin((i-fov/2)*DEG2RAD));
          
          float rx = ray.hit_x();
          float ry = ray.hit_y();
      // void draw_line(float x1, float y1,
      //   float x2, float y2, float width, uint colour);
//        puts(i+" "+pos.x+" "+pos.y+" "+rx+" "+ry);
          // if(rx == 0) {
          //    puts(i+
          //    " "+
          //    pos.x+
          //    " "+
          //    pos.y+
          //    " "+
          //    (pos.x + mapHeight * cos((i-45)*DEG2RAD) * facing)+
          //    " "+
          //    (pos.y + mapHeight * sin((i-45)*DEG2RAD)));

          //    c.draw_line(
          // pos.x, 
          // pos.y, 
          // pos.x + mapHeight * cos((i-45)*DEG2RAD) * facing,
          // pos.y + mapHeight * sin((i-45)*DEG2RAD), 1, BLUE);

          // }
//          float dist = distance(pos.x, pos.y, rx, ry);
          float dist = abs(pos.x - rx);
          c.draw_line(pos.x, pos.y, rx, ry, 1, RED);

          /* Returns 0-3 indicating the side of the edge hit from
            * top, bottom, left, right in that order. */
          //int tile_side();

          uint color = ray.tile_side() == 0 || ray.tile_side() == 1 ? BLUE : BLUE/2;
          if(dist !=0){
            c.draw_line(mapWidth/2 - block_width/sqrt(dist), 
            (i*(mapHeight/fov)), 
            mapWidth/2+block_width/sqrt(dist), 
            (i*(mapHeight/fov)), 
            mapHeight/fov, 
            color);
          }
          /*c.draw_line(
          pos.x, 
          pos.y, 
          pos.x + mapHeight * cos((i/fov)*fov*DEG2RAD) * facing,
          pos.y + mapHeight * sin((i/fov)*fov*DEG2RAD) * facing, 5, BLUE);*/
    }
  }


   void debug_draw() {
    c.draw_rectangle(0, 0, mapWidth, mapHeight, 0, WHITE);
    c.draw_rectangle(X1, Y1, X1+10, Y1+10, 0, GREEN);
   }
}

