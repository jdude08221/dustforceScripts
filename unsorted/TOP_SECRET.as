#include '../jlib/const/ColorConsts.as'
const string EMBED_sound1 = "wearefinallylanding.ogg"; 
class script{
  int ent = 2409;
  scene@ g;
  float pos_y;
  int rect_size = 48;
  int flag_size = 25;
  audio@ a;
  script() {
    @g = get_scene();
  }

  void on_level_start() {
    if(@a == null || !a.is_playing()) {
      @a = g.play_persistent_stream('sound1', 1, true, 2, true);
    }
  }

  void build_sounds(message@ msg) {
    msg.set_string("sound1", "sound1");
    msg.set_int("sound1|loop", 2884875);
  }

  void step(int entities) {

  }

  void draw(float sub_frame) {

  }

  void editor_draw(float sub_frame) {
    g.draw_line(22, 20, 3777, -46240, 3987, -45936, 4, 0xFFFF0000);
    sprites@ spr = create_sprites();
    spr.add_sprite_set("editor");
    spr.draw_world(18, 5, "levelend", 0, 0, 3986, -45936, 0, 1, 1, 0xFFFFFFFF); 
    g.draw_rectangle_world(18, 6, 3986 - rect_size, -45936 - rect_size-flag_size, 3986 + rect_size, -45936 + rect_size-flag_size, 0, 0x2FFFFFFF);
  }

  void entity_on_remove(entity@ e) {
    //load level?
  }
}