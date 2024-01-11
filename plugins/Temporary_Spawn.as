#include '../lib/enums/VK.cpp';
#include '../jlib/const/ColorConsts.as'
/*
 * Plugin that allows a user to set a temporary spawn without overriding the devault level spawn
 */
class script
{
    scene@ g;
    input_api@ i;

    [hidden] bool is_spawn_set = false;
    [hidden] float spawn_x = 0;
    [hidden] float spawn_y = 0;

    camera@ cam;

    bool enable_key_pressed = false;
    bool alt_key_pressed = false;
    bool reset_camera = false;

    script() {
      @g = get_scene();
      @i = get_input_api();
    }

    void on_level_start() {
      // At level start, move player to temporary start and update camera position
      if(is_spawn_set) {
        entity@ c = controller_entity(0);
        camera@ cam = get_camera(0);
        cam.script_camera(true);
        cam.x(spawn_x);
        cam.y(spawn_y);
        c.x(spawn_x);
        c.y(spawn_y);
        reset_camera = true;
      }
    } 

    void step(int entities) {
      // Disable script camera as we set it to a static position in on_level_start
      if(@cam == null) {
        @cam = get_camera(0);
      }
      
      if(cam.script_camera() && reset_camera) {
        cam.script_camera(false);
      }
    }

    void editor_step() {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(i.is_polling_keyboard()) {
        return;
      }
      // == 2. Collect user input
      enable_key_pressed = i.key_check_vk(VK::Z);
      alt_key_pressed = i.key_check_vk(VK::Menu);

      // == 3. Update spawn while enable key (Z) is held. If alt + enable key is pressed, remove temporary spawn
      if(enable_key_pressed) {
        if(!alt_key_pressed) {
          is_spawn_set = true;
          spawn_x = i.mouse_x_world(19);
          spawn_y = i.mouse_y_world(19);
        } else {
          is_spawn_set = false;
        }
      }
    }

    void editor_draw(float sub_frame) {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(i.is_polling_keyboard()) {
        return;
      }
     // == 2. If a spawn point has been set, draw spawn point sprite ==
      if(is_spawn_set) {
        sprites@ spr = create_sprites();
        spr.add_sprite_set("dustman");
        // void draw_world(int layer, int sub_layer, string spriteName, uint3 2 frame, uint32 palette, float x, float y, float rotation, float scale_x, float scale_y, uint32 colour);
        spr.draw_world(22, 0, "idle", 0, 0, spawn_x, spawn_y, 0, 1, 1, 0xFF000000);
      }
    }
}
