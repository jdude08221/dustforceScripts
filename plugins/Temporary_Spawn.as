#include '../lib/enums/VK.cpp';
#include '../jlib/const/ColorConsts.as'
/*
 * Plugin that allows a user to set a temporary spawn without overriding the devault level spawn
 */
class script
{
    scene@ g;
    input_api@ i;
    camera@ cam;

    [hidden] bool is_spawn_set = false;
    [hidden] float spawn_x = 0;
    [hidden] float spawn_y = 0;
    [hidden] float facing = 1;

    bool enable_key_pressed = false;
    bool alt_key_pressed = false;
    bool ctrl_key_pressed = false;
    bool dir_key_pressed = false;

    script() {
      @g = get_scene();
      @i = get_input_api();
    }

    void on_level_start() {
      // == 1. At level start, move player to temporary start if it exists and update camera position ==
      if(is_spawn_set) {
        entity@ c = controller_entity(0);
        camera@ cam = get_camera(0);
        cam.script_camera(true);
        cam.x(spawn_x);
        cam.y(spawn_y);
        c.x(spawn_x);
        c.y(spawn_y);
        c.face(facing);
        //== 2. After player and camera has been moved, reset camera so it centers on player ==
        cam.script_camera(false);
        reset_camera(0);
        
      }
    } 
    
    void editor_step() {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(@i != null && i.is_polling_keyboard()) {
        return;
      }

      // == 2. Collect user input
      enable_key_pressed = i.key_check_vk(VK::F);
      alt_key_pressed = i.key_check_vk(VK::Menu);
      ctrl_key_pressed = i.key_check_vk(VK::Control);
      dir_key_pressed = i.key_check_pressed_vk(VK::Left) || i.key_check_pressed_vk(VK::Right);
      
      // == 3. Update spawn while enable key (Z) is held. If alt + enable key is pressed, remove temporary spawn
      if(enable_key_pressed && !ctrl_key_pressed) { // check ctrl key to avoid false positives with ctrl+z
        if(!alt_key_pressed) {
          is_spawn_set = true;
          spawn_x = i.mouse_x_world(19);
          spawn_y = i.mouse_y_world(19);
          if(dir_key_pressed) { // updating facing if user presses direction key
            facing = facing == 1 ? -1 : 1;
          }
        } else {
          is_spawn_set = false;
        }
      }
    }

    void editor_draw(float sub_frame) {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(@i != null && i.is_polling_keyboard()) {
        return;
      }

     // == 2. If a spawn point has been set, draw temporary spawn point sprite ==
      if(is_spawn_set) {
        sprites@ spr = create_sprites();
        spr.add_sprite_set("dustman");
        spr.draw_world(22, 0, "idle", 0, 0, spawn_x, spawn_y, 0, facing, 1, BLACK);
      }
    }
}
