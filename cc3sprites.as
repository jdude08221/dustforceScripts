#include "../lib/drawing/Sprite.cpp"

const string EMBED_spr10 = "CC/Alex.png";
const string EMBED_spr20 = "CC/Delo.png";
const string EMBED_spr30 = "CC/Mad.png";
const string EMBED_spr40 = "CC/Temp.png";
const string EMBED_spr50 = "CC/Simon.png";
const string EMBED_spr60 = "CC/Corc.png";

class script
{
    scene@ g;
    sprites@ spr;
    [text]array<SpriteHelper> sh;
    script() {
      @g = get_scene();
      @spr = create_sprites();
    }

   void build_sprites(message@ msg) {
      msg.set_string("spr10","spr10");
      msg.set_string("spr20","spr20"); 
      msg.set_string("spr30","spr30"); 
      msg.set_string("spr40","spr40"); 
      msg.set_string("spr50","spr50"); 
      msg.set_string("spr60","spr60"); 
   }

    void on_level_start()
    {
      //g.override_stream_sizes(10, 8);
      spr.add_sprite_set("script");
    }

    void checkpoint_load()
    {
        
    }

    void step(int)
    {
       spr.add_sprite_set("script");
    }

    void editor_step() {
      spr.add_sprite_set("script"); 
    }

    void draw(float) {
      for(uint i = 0; i < sh.size(); i++) {
        spr.draw_world(18, 1, sh[i].spriteName, 0, 1, sh[i].X1, sh[i].Y1,
                       sh[i].rotation, sh[i].scale, sh[i].scale, 0xFFFFFFFF);
      }
    }

    void editor_draw(float)
    {
      // for(uint i = 0; i < sh.size(); i++) {
      //   spr.draw_world(18, 1,sh[i].spriteName, 0, 1, sh[i].X1, sh[i].Y1,
      //                  sh[i].rotation, sh[i].scale, sh[i].scale, 0xFFFFFFFF);
      // }
    }
}

class SpriteHelper {
  [position,mode:world,layer:19,y:Y1] float X1;
  [hidden] float Y1;
  [text]string spriteName;
  [angle] float rotation;
  [text] float scale;
  SpriteHelper() {
    scale = 1;
    rotation = 0;
    X1 = 0;
    Y1 = 0;
  }

  string toString() {
    return "X1: "+X1+" Y1: "+Y1+" spriteName: "+spriteName+" rotation: "+rotation+" scale: "+scale;
  }
}
