#include "../lib/drawing/Sprite.cpp"
const string EMBED_spr1 = "snowboard/large.png";
const uint WHITE = 0xFFFFFFFF; 
const uint MAX_SPEED = 100; 
const uint MINSPEED = 10; 

const uint ACCEL = 50;
const uint ACCEL_FORCE = 80;
const float GRAVITY = 50;
const float FRICTION = -20;

class script
{
    scene@ g;
    sprites@ spr;
    [hidden]Sprite spr1;
    [text]array<SpriteHelper> sh;
    [hidden]float x, y;
    [hidden]float lxspd, lyspd;
    array<float>lastSpeed(8);
    script() {
      @g = get_scene();
      @spr = create_sprites();
      x = 0;
      y = 0;
      lastSpeed[0] = 0;
      lastSpeed[1] = 0;
      lastSpeed[2] = 0;
      lastSpeed[3] = 0;
      lastSpeed[4] = 0;
      lastSpeed[5] = 0;
      lastSpeed[6] = 0;
      lastSpeed[7] = 0;
    }

   void build_sprites(message@ msg) {
      msg.set_string("spr1","spr1");
   }

    void on_level_start()
    {
      spr.add_sprite_set("script");
      spr1.set("script", "spr1");
    }

    void checkpoint_load()
    {
        
    }

    void step(int)
    { 
       spr.add_sprite_set("script");
       for (uint i = 0; i < 4; i++) {
        if(controller_entity(i) != null) {
          dustman@ dm = controller_entity(i).as_dustman();
          //move on ground only
          
          if(dm.ground()) {
            if(dm.x_speed() < MINSPEED) {
              dm.set_speed_xy(MINSPEED, dm.y_speed());
              lastSpeed[i*2] = MINSPEED;
            }
            if(dm.x_intent() == -1) {
              //left accel
              dm.set_speed_xy(lastSpeed[i*2] - ACCEL_FORCE, dm.y_speed());
              if((lastSpeed[i*2] -= ACCEL) > MAX_SPEED) {
                lastSpeed[i*2] -= ACCEL_FORCE;
              }
            } else if(dm.x_intent() == 1){
              //right accel
              dm.set_speed_xy(lastSpeed[i*2] + ACCEL_FORCE, dm.y_speed());
              if((lastSpeed[i*2] += ACCEL) < MAX_SPEED) {
                lastSpeed[i*2] += ACCEL_FORCE;
              }
            }
            if(dm.ground_surface_angle() < 0) {
              if(dm.ground_surface_angle() == -45) {
                dm.state(18);
              }
                
              //left accel
              dm.set_speed_xy(lastSpeed[i*2] - ACCEL, dm.y_speed());
              if((lastSpeed[i*2] -= ACCEL) > MAX_SPEED) {
                lastSpeed[i*2] -= ACCEL;
              }
            } else if(dm.ground_surface_angle() > 0){
              if(dm.ground_surface_angle() == 45) { 
                //dm.state(18);
              }
                
              //right accel
              dm.set_speed_xy(lastSpeed[i*2] + ACCEL, dm.y_speed()-10);
              if((lastSpeed[i*2] += ACCEL) < MAX_SPEED) {
                lastSpeed[i*2] += ACCEL;
              }
            } else {
              dm.state(0);
               if(dm.face() == 1) {
                if(lastSpeed[i*2] + FRICTION > 0) {
                  dm.set_speed_xy(lastSpeed[i*2] + FRICTION * (dm.face()), dm.y_speed());
                  lastSpeed[i*2] += FRICTION * (dm.face());
                } else {
                  dm.set_speed_xy(MINSPEED, dm.y_speed());
                  lastSpeed[i*2] = MINSPEED;
                }
                
              } else {
                if(lastSpeed[i*2] + FRICTION < 0) {
                  dm.set_speed_xy(lastSpeed[i*2] - FRICTION * (dm.face()), dm.y_speed());
                  lastSpeed[i*2] -= FRICTION * (dm.face());
                } else {
                  dm.set_speed_xy(-MINSPEED, dm.y_speed());
                  lastSpeed[i*2] = -MINSPEED;
                }
              }
            }
          } else {
            
             lastSpeed[i*2] = dm.x_speed();
             lastSpeed[i*2+1] = dm.y_speed();
          }
        }
       }
       
    }

    void editor_step() {
      spr.add_sprite_set("script");
    }
     void pre_draw(float sub_frame) {
    for (uint i = 0; i < 4; i++) {
        if(controller_entity(i) != null) {
          dustman@ dm = controller_entity(0).as_dustman();
          //Draw sprite
          if(dm.ground()) {
            dm.sprite_index("idle");
          }
        }
      }
  }
    void draw(float) {
      spr1.set("script", "spr1");
      for (uint i = 0; i < 4; i++) {
        if(controller_entity(i) != null) {
          dustman@ dm = controller_entity(0).as_dustman();
          //Draw sprite
          //if(dm.ground()) {
            //dm.sprite_index("idle");
          //}
          draw_spr(0, 0, dm);
          //Do physics
        }
      }
    }

    void editor_draw(float)
    {
      spr1.set("script", "spr1");
      for(uint i = 0; i < sh.size(); i++) {
        spr1.draw(sh[i].layer, sh[i].sublayer, 0, 0, sh[i].X1, 
              sh[i].Y1, sh[i].rotation, sh[i].scale , sh[i].scale, WHITE);
      }
    }

    void draw_spr(float x, float y, dustman@ dm) {
      for(uint i = 0; i < sh.size(); i++) {
        spr1.draw(sh[i].layer, sh[i].sublayer, 0, 0, dm.x(), 
              dm.y(), dm.ground_surface_angle(), dm.face(), sh[i].scale, WHITE);
      }
    }
}

class SpriteHelper {
  [position,mode:world,layer:19,y:Y1] float X1;
  [hidden] float Y1;
  [hidden]string spriteName;
  [angle] float rotation;
  [text] float scale;
  [text] int layer;
  [text] int sublayer;
  SpriteHelper() {
    scale = 1;
    rotation = 0;
    X1 = 0;
    Y1 = 0;
    layer = 20;
    sublayer = 1;
    spriteName = "spr1";
  }

  string toString() {
    return "X1: "+X1+" Y1: "+Y1+" spriteName: "+spriteName+" rotation: "+rotation+" scale: "+scale;
  }
}

