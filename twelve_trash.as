#include "lib/utils/print_vars.cpp"
const int NUM_FRAMES = 22; 
const string EMBED_out1 = "frames/out1.png";
const string EMBED_out2 = "frames/out2.png";
const string EMBED_out3 = "frames/out3.png";
const string EMBED_out4 = "frames/out4.png";
const string EMBED_out5 = "frames/out5.png";
const string EMBED_out6 = "frames/out6.png";
const string EMBED_out7 = "frames/out7.png";
const string EMBED_out8 = "frames/out8.png";
const string EMBED_out9 = "frames/out9.png";
const string EMBED_out10 = "frames/out10.png";
const string EMBED_out11 = "frames/out11.png";

const string EMBED_out12 = "frames_twelve_idle/out1.png";
const string EMBED_out13 = "frames_twelve_idle/out2.png";
const string EMBED_out14 = "frames_twelve_idle/out3.png";
const string EMBED_out15 = "frames_twelve_idle/out4.png";
const string EMBED_out16 = "frames_twelve_idle/out5.png";
const string EMBED_out17 = "frames_twelve_idle/out6.png";
const string EMBED_out18 = "frames_twelve_idle/out7.png";
const string EMBED_out19 = "frames_twelve_idle/out8.png";
const string EMBED_out20 = "frames_twelve_idle/out9.png";
const string EMBED_out21 = "frames_twelve_idle/out10.png";
const string EMBED_out22 = "frames_twelve_idle/out11.png";

//"invisible" sprites
const string EMBED_blank = "invis/blank.png";
const string EMBED_axe = "dlc2/twelve_axe.ogg";
class EntityData {
  [entity] uint id;
  bool attacking;
  uint attackTimer;
  uint attackFrameCount;
}

class script : callback_base{
  int frame_count;
  int draw_frame_count;
  int curSpriteIndex;
  uint attackWindup = 18;
  sprites@ spr;
  scene@ g;

  [text] int layer;
  [text] bool showSprite;
  [text] float scale;
  [text] array<EntityData> enemies(0);
  

  [hidden] float Y1;
 
  
  array<string>framesGlobal(NUM_FRAMES);
  script() {
    @g = get_scene();
    layer = 20;
    scale = 1;
    frame_count = 0;
    draw_frame_count = 0;
    curSpriteIndex = 0;
    @spr = create_sprites();
    framesGlobal[11] = "out11";
  }

  void build_sounds(message@ msg) {
    msg.set_string("axe", "axe");
  }

  void build_sprites(message@ msg) {
    for(int i = 1; i <= NUM_FRAMES; i++) {
      msg.set_string("out"+i,"out"+i); 
    }
    msg.set_string("attack","blank");
    msg.set_string("cue","blank");
    msg.set_string("idle","blank");
    msg.set_string("turn","blank");
    msg.set_string("walk","blank");
    msg.set_string("attackeffect","blank");
    msg.set_string("cfall1","blank");
    msg.set_string("chover1","blank");
    msg.set_string("cidle1","blank");
    msg.set_string("cland1","blank");
    msg.set_string("cleansed1","blank");
    msg.set_string("cthanks1","blank");
  }

  void on_level_start() {
    g.override_sound("sfx_trashbeast_attack", "axe", true);

    //Populate names of frames into global frame array
    for(int i = 1; i <= NUM_FRAMES; i++) {
      framesGlobal[i-1] = "out" + i;
    }

    spr.add_sprite_set("script");  
    
    for(uint i = 0; i < enemies.size(); i++) {
      enemies[i].attacking = false;
      enemies[i].attackTimer = 0;
      enemies[i].attackFrameCount = 0;
    }
  }
  
  void step(int) {
    //Only advance animation frame every 6 game ticks
    if(frame_count%4 == 0) {
      curSpriteIndex++;
    }
    
    if(frame_count%5 == 0) {
      for(uint i = 0; i < enemies.size(); i++) {
        if(enemies[i].attackTimer > attackWindup) {
          enemies[i].attackFrameCount++;
        }
      }
    }
   for(uint i = 0; i < enemies.size(); i++) {
      int id = enemies[i].id;
      entity@ e = entity_by_id(enemies[i].id);

      if(@e == null) {
        continue;
      }
      
      e.set_sprites(spr);

      int state = e.as_controllable().state();
      int attackState = e.as_controllable().attack_state();
      
      enemies[i].attacking = attackState > 0;
      if(enemies[i].attacking || enemies[i].attackFrameCount < 11 && enemies[i].attackTimer > attackWindup) {
        enemies[i].attackTimer++;
        
      } else {
        if(enemies[i].attackTimer > 0)
        enemies[i].attackTimer = 0;
        enemies[i].attackFrameCount = 0;
      }
   }
    frame_count++;
  }

  void editor_draw(float subframe) {}

  void editor_step() {
    spr.add_sprite_set("script");
  }

  void entity_on_add(entity@ e) {
    if(@e != null) {
      //Removes effect sprites for trash bear
      if(e.type_name() == "effect") {
        if(e.get_sprites().get_sprite_count("trash_beast") > 0) {
          e.get_sprites().add_sprite_set("script");
        }
      }

      //Removes hitbox sprite for trash bear
      if(@e.as_hitbox() != null && 
        @e.as_hitbox().owner() != null && 
        e.as_hitbox().owner().type_name() == "enemy_trash_beast") {
        e.as_hitbox().attack_effect("");
      }
    }
  }

  void draw(float subframe) {
    for(uint i = 0; i < enemies.size(); i ++) {
      entity@ e = entity_by_id(enemies[i].id);
      if(@e == null) {
        continue;
      }

      float x = e.x() + 15*e.face();
      float y = e.y();
      
      if(enemies[i].attackTimer > attackWindup) {
        //draw attacking frames
        spr.draw_world(layer, 8, framesGlobal[(enemies[i].attackFrameCount)], 0, 1, x-175*e.face(), y-145, 0, (scale+.5) * e.face(), scale + .30, 0xFFFFFFFF);
      } else {
        spr.draw_world(layer, 8, framesGlobal[11+(curSpriteIndex % 11)], 0, 1, x-75*e.face(), y-115, 0, (scale + .25) * e.face(), scale + .30, 0xFFFFFFFF);
      }
    }
    draw_frame_count++;
  }
}