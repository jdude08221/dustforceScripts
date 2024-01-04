#include '../lib/enums/VK.cpp';
#include '../jlib/const/ColorConsts.as'

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
      alt_pressed = i.key_check_vk(VK::Menu);
      if(i.key_check_pressed_vk(VK::M)) {
        draw_mouse_pos = !draw_mouse_pos;
      }

      // Default ruler layer is the user selected layer. If alt is currently held,
      // Switch to layer 22
      selected_layer = !alt_pressed ? e.get_selected_layer() : 22;

      mouse_x = i.mouse_x_world(selected_layer);
      mouse_y = i.mouse_y_world(selected_layer);

      // First frame A key is pressed, init vars needed to draw ruler
      // and hide the gui
      if(i.key_check_pressed_vk(VK::A)) {
        is_active = true;
        e.hide_gui(true);
        start_x = mouse_x;
        start_y = mouse_y;
      }

      // Deactivate ruler and cleanup when A key is released
      if(!i.key_check_vk(VK::A) && is_active) {
        is_active = false;
        e.hide_gui(false);
      }

      // While active, update distances and textfield values. These values
      // are used for drawing the selection and textfield.
      if(is_active) {
        x_dist = abs((floor(start_x/48)) - (floor(mouse_x/48))) + 1;
        y_dist = abs((floor(start_y/48)) - (floor(mouse_y/48))) + 1;
        t.text(x_dist + " X "+ y_dist);
        t2.text(t.text());
      }
    }

    void editor_draw(float sub_frame) {
      // Draw mouse's current position in the world
      if(draw_mouse_pos) {
        mouse_pos_t.colour(WHITE); // Text
        mouse_pos_t2.colour(BLACK); // Dropshadow

        mouse_pos_t.text("(" + floor(mouse_x/48) + ", " + floor(mouse_y/48) + ")");

        // When alt is pressed, append current layer
        if(alt_pressed ) {
          mouse_pos_t.text(mouse_pos_t.text() + " Layer " + selected_layer);
        }
        mouse_pos_t2.text(mouse_pos_t.text());  

        // Draw text below cursor
        mouse_pos_t2.draw_world(22, 22, i.mouse_x_world(22) + 2, 
                     i.mouse_y_world(22) + ceil(mouse_pos_t.text_height() / 2) * scale + 20, scale, scale, 0);
        mouse_pos_t.draw_world(22, 22, i.mouse_x_world(22), 
                     i.mouse_y_world(22) + ceil(mouse_pos_t.text_height() / 2) * scale + 20, scale, scale, 0);
      }

      if(is_active) {
        // Draw transparent squares with outlines that are contained 
        // within user's ruler selection. 
        // (Could be optimized by saving squares in selection insetad 
        // of recalculating them all each step)
        for(int i = 0; i < x_dist; i++) {
          for(int j = 0; j < y_dist; j++) {
            float x = floor(start_x/48) * (48) + 
                      sign(mouse_x - start_x) * ((48 * (i)));
            float y = floor(start_y/48) * (48) + 
                      sign(mouse_y - start_y) * ((48 * (j)));

            // Transparent square
            g.draw_rectangle_world(selected_layer, 20, 
            x, y, x + 48, y + 48, 
            0, TRANSPARENT_GREEN);

            // Outline
            draw_rect_outline(x, y, x + 48, y + 48);
          }
        }

        // Draw text with drop shadow containing X, Y taxicab distance
        t2.draw_world(22, 22, i.mouse_x_world(22) + 2, 
                     i.mouse_y_world(22) - (48 * scale), scale, scale, 0);

        t.draw_world(22, 22, i.mouse_x_world(22), 
                     i.mouse_y_world(22) - (48 * scale), scale, scale, 0);
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
