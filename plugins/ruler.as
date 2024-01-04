#include '../lib/enums/VK.cpp';
#include '../jlib/const/ColorConsts.as'

const uint TILESIZE = 48; // Tile size in raw units
/*
 * Script that allows a user to hold the "a" key while in editor
 * to measure the X and Y distance between tiles
 */
class script
{
    // Required handles to draw to the screen, detect the current editor tab,
    // and get user's input
    scene@ g;
    editor_api@ e;
    input_api@ i;

    // Textfields are updated to the current ruler measurement in step().
    // There are two textfields so we can draw a dropshadow behind the text
    // for ease of reading
    textfield@ t; 
    textfield@ t2;

    // Textfields are updated to the current mouse position in step().
    // see dropshadow comment in previous comment
    textfield@ mouse_pos_t;
    textfield@ mouse_pos_t2;

    // tracks the current position of the mouse on the screen
    float mouse_x = 0;
    float mouse_y = 0;

    // When starting a selection, we need to keep track of the first tile a user
    // was hovering over. start_x and start_y hold this value
    float start_x = 0;
    float start_y = 0;

    // Current distance computed from user's selection
    float x_dist = 0;
    float y_dist = 0;

    // Scale specifically used for the text size
    float scale = .5;

    // Stores user's currently selected layer for the plugin. Defaults
    // to user's selected layer (see step()) and is set to 22 while user is
    // holding alt
    int selected_layer = 22;

    // Flag that tracks if ruler if currently active
    bool is_active = false;

    // Flag that tracks if "show mouse position" feature is enabled
    bool draw_mouse_pos = false;

    bool alt_pressed = false;
    bool shift_pressed = false;

    script() {
      @g = get_scene();
      @e = get_editor_api();
      @i = get_input_api();
      @t = create_textfield();
      @t2 = create_textfield();
      @mouse_pos_t = create_textfield();
      @mouse_pos_t2 = create_textfield();

      t.colour(WHITE);
      t2.colour(BLACK);

      mouse_pos_t.colour(WHITE);
      mouse_pos_t2.colour(BLACK);
    }

    void editor_step() {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(i.is_polling_keyboard()) {
        return;
      }

      // == 2. Collect user keyboard input ==
      bool a_pressed = i.key_check_pressed_vk(VK::A);
      bool a_held = i.key_check_vk(VK::A);
      alt_pressed = i.key_check_vk(VK::Menu);
      if(i.key_check_pressed_vk(VK::M)) {
        draw_mouse_pos = !draw_mouse_pos;
      }

      // == 3. Get layer selection configuration and update mouse position vars
      selected_layer = !alt_pressed ? e.get_selected_layer() : 22; // Determine layer dynamically based on if alt key is pressed
      mouse_x = i.mouse_x_world(selected_layer);
      mouse_y = i.mouse_y_world(selected_layer);

      // == 4. Setup vars if a key is freshly pressed ==
      if(a_pressed) {
        is_active = true;
        e.hide_gui(true);
        start_x = mouse_x;
        start_y = mouse_y;
      }

      // == 5. Handle deactivation ==
      if(!a_held && is_active) {
        is_active = false;
        e.hide_gui(false);
      }

      // == 6. Update distances and textfields ==
      if(is_active) {
        x_dist = abs((floor(start_x/TILESIZE)) - (floor(mouse_x/TILESIZE))) + 1; // + 1 because we want to include the start tile
        y_dist = abs((floor(start_y/TILESIZE)) - (floor(mouse_y/TILESIZE))) + 1; // + 1 because we want to include the start tile
        t.text(x_dist + " X "+ y_dist);
        t2.text(t.text());
      }
    }

    void editor_draw(float sub_frame) {
      // == 1. Abort all functionality if user is entering text elsewhere (text trigger, compiling script, etc.) ==
      if(i.is_polling_keyboard()) {
        return;
      }

      // == 2. Draw mouse's current position in the world if setting is enabled ==
      if(draw_mouse_pos) {
        // Create 2 additional textfields to show the tile coordinates in addition to raw coordinates 
        textfield@ mouse_pos_t_tile = create_textfield(); // Text
        textfield@ mouse_pos_t_tile2 = create_textfield(); // Dropshadow

        // Setup text color and dropshadows
        mouse_pos_t_tile.colour(WHITE);
        mouse_pos_t_tile2.colour(BLACK);
        mouse_pos_t.colour(WHITE);
        mouse_pos_t2.colour(BLACK);

        // Set text of tile coordinates
        mouse_pos_t_tile.text("(" + floor(mouse_x/TILESIZE) + ", " + floor(mouse_y/TILESIZE) + ")");
        mouse_pos_t_tile2.text(mouse_pos_t_tile.text());

        // Set text of raw coordinates
        mouse_pos_t.text("(" + mouse_x + ", " + mouse_y/TILESIZE + ")");
        mouse_pos_t2.text(mouse_pos_t.text());  

        // Calculate margin between mouse cursor and where we print the mouse position
        float text_top_margin = ceil(mouse_pos_t.text_height() / 2) * scale + 20;

        // Tile coordinates
        mouse_pos_t2.draw_world(22, 22, i.mouse_x_world(22) + 2, 
                     i.mouse_y_world(22) + text_top_margin, scale, scale, 0);
        mouse_pos_t.draw_world(22, 22, i.mouse_x_world(22), 
                     i.mouse_y_world(22) + text_top_margin, scale, scale, 0);
        // Raw coordinates (drawn below tile coordinates)
        mouse_pos_t_tile2.draw_world(22, 22, i.mouse_x_world(22) + 2, 
                     i.mouse_y_world(22) + text_top_margin + mouse_pos_t.text_height(), scale, scale, 0);
        mouse_pos_t_tile.draw_world(22, 22, i.mouse_x_world(22), 
                     i.mouse_y_world(22) + text_top_margin + mouse_pos_t.text_height(), scale, scale, 0);
        
      }

      // == 3. Draw selection if ruler is active ==
      if(is_active) {
        // Draw transparent squares with outlines within user's ruler selection. 
        // Potential optimizations:
        // 1. Save squares contained in selection insetad of recalculating each step
        // 2. Avoid double drawing lines where square edges touch
        for(int i = 0; i < x_dist; i++) {
          for(int j = 0; j < y_dist; j++) {
            float x = floor(start_x/TILESIZE) * (TILESIZE) + 
                      sign(mouse_x - start_x) * ((TILESIZE * (i)));
            float y = floor(start_y/TILESIZE) * (TILESIZE) + 
                      sign(mouse_y - start_y) * ((TILESIZE * (j)));

            // Transparent square
            g.draw_rectangle_world(selected_layer, 20, x, y, x + TILESIZE, y + TILESIZE, 
            0, TRANSPARENT_GREEN);

            // Outline (will draw double lines where rectangles overlap but for most use cases this shouldnt be an issue)
            draw_rect_outline(x, y, x + TILESIZE, y + TILESIZE);
          }
        }

        // Draw text with drop shadow containing X, Y distance
        t2.draw_world(22, 22, i.mouse_x_world(22) + 2, 
                     i.mouse_y_world(22) - (TILESIZE * scale), scale, scale, 0);
        t.draw_world(22, 22, i.mouse_x_world(22), 
                     i.mouse_y_world(22) - (TILESIZE * scale), scale, scale, 0);
      }
    }

    /*
    * Function takes 2 points, (x1, y1) and (x2, y2) and draws 
    * a reactangle out of lines
    */
    void draw_rect_outline(float x1, float y1, float x2, float y2) {
      //Top Line
      g.draw_line_world(selected_layer, 20, 
                        x1, y1, x2, y1, 2, GREEN);

      //Right Line
      g.draw_line_world(selected_layer, 20, 
                        x2, y1, x2, y2, 2, GREEN);

      //Bottom Line
      g.draw_line_world(selected_layer, 20, 
                        x1, y2, x2, y2, 2, GREEN);

      //Left Line
      g.draw_line_world(selected_layer, 20, 
                        x1, y1, x1, y2, 2, GREEN);
    }

    /*
    * Function takes a value and returns the sign of it.
    * A value of 0 returns +
    */
    float sign(float val) {
      return val >= 0 ? 1 : -1;
    }
}
