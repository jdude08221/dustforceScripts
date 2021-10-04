#include "../lib/math/Rect.cpp"
#include "../lib/ui/Button.cpp"
#include "../lib/ui/label.cpp"
#include "../lib/ui/UI.cpp"

#include "../lib/math/math.cpp"

#include "jlib/const/ColorConsts.as"
#include "jlib/ui/CustomCanvas.as"
#include "jlib/ui/ColorSwab.as"
#include "jlib/ui/LabelButton.as"

const float BUTTON_SPACING = 20;
const uint NUM_COLOR_BUTTONS = 32;
class script : callback_base{
  scene@ g;
  UI@ ui = UI();
  Mouse@ mouse = ui.mouse;

  uint cur_color;
  uint temp_color;

  bool right_mouse_down;
  [hidden] uint numPlayers;
  [text]CustomCanvas custom_canvas;
  [text] float pixelSize;
  [position,mode:world,layer:18,y:bY1] float bX1;
  [hidden] float bY1;

  [position,mode:world,layer:18,y:cbY1] float cbX1;
  [hidden] float cbY1;

  [position,mode:world,layer:18,y:ebY1] float ebX1;
  [hidden] float ebY1;

  [text] float brush_width;

  [hidden] array<ColorButton@> color_buttons(NUM_COLOR_BUTTONS);

  [hidden]LabelButton @clear_button;
  [hidden]LabelButton @end_button;

  array<Pixel@> drawing();
  uint code_index;

  script() {
    code_index = 0;
    @g = get_scene();
    brush_width = pixelSize;
    init_buttons();
    cur_color = BLACK;
    temp_color = WHITE;
    add_broadcast_receiver('color_picked', this, 'update_color');
    add_broadcast_receiver('clear_canvas', this, 'clear_canvas');
    add_broadcast_receiver('end_level', this, 'end_level');
    right_mouse_down = false;
  }

  void update_color(string id, message@ msg) {
    if(msg.get_string('color_change') == 'true') {  
      cur_color = msg.get_int("color");
    }
  }

  void clear_canvas(string id, message@ msg) {
    if(msg.get_string('clear_canvas') == 'true') {  
      //clear canvas
      dustman@ dm = controller_entity(0).as_dustman();
      entity@ e = create_entity("enemy_stoneboss");
      e.as_controllable().scale(5, false);
      e.set_xy(dm.x(), dm.y()-200);
      e.as_controllable().attack_state(1);
      g.add_entity(e);
    }
  }
  
  void end_level(string id, message@ msg) {
    if(msg.get_string('end_level') == 'true') {  
      g.end_level(0,0);
    }
  }

  void on_level_start() {
    init_buttons();
    custom_canvas.init(pixelSize);
  }

  void init_buttons() {
    for(uint i = 0; i < color_buttons.size(); i++) {
      //Set up each color button. Each row of colors is 16 long
      @color_buttons[i] = ColorButton(ui, COLOR_LIST[i], 
      bX1 + (BUTTON_SPACING + ui.padding) * (i % 16), 
      bY1 + (BUTTON_SPACING + ui.padding) * (i/16));
    }
    
    @clear_button  = LabelButton(ui, cbX1, cbY1, "clear_canvas", "Clear");
    @end_button  = LabelButton(ui, ebX1, cbY1, "end_level", "Done!");
  }

  void build_sounds(message@ msg) {
    //TODO: implement music
  }

  //taunt, light, heavy, light, dash, dash, taunt
  void update_code(dustman@ dm) {
    switch(code_index) {
      case 0:
        if(dm.taunt_intent() == 1 && 
        dm.heavy_intent() == 0 &&
        dm.light_intent() == 0 &&
        dm.dash_intent() == 0 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else {
          code_index = 0;
        }
        break;
      case 1:
      if(dm.taunt_intent() == 0 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 1 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(dm.taunt_intent() != 0 ||
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 2:
      if(dm.taunt_intent() == 0 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 1 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(dm.taunt_intent() != 0 ||
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 3:
      if(dm.taunt_intent() == 0 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 1 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(dm.taunt_intent() != 0 ||
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 4:
      if(dm.taunt_intent() == 0 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 1 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(dm.taunt_intent() != 0 ||
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 5:
      if(dm.taunt_intent() == 0 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 1 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(dm.taunt_intent() != 0 ||
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 6:
       if(dm.taunt_intent() == 1 && 
        dm.heavy_intent() != 10 &&
        dm.light_intent() != 10 &&
        dm.dash_intent() == 0 &&
        dm.jump_intent() == 0) {
          code_index++;
        } else if(
        dm.heavy_intent() == 10 ||
        dm.light_intent() == 10 ||
        dm.dash_intent() != 0 ||
        dm.jump_intent() != 0){
          code_index = 0;
        }
        break;
      case 7:
        g.end_level(dm.x(), dm.y());
        break;

    }
  }

  void step(int) {
    ui.step();
    custom_canvas.updatePixelSize(pixelSize);
  
    if(@controller_entity(0) == null) {
      return;
    }

    dustman@ dm = controller_entity(0).as_dustman();
    update_code(dm);

    //handle mouse inputs
    right_mouse_down = get_right_mouse_down(0);

    if(get_mouse_scroll_down(0)) {
      if(brush_width > 5 && brush_width - pixelSize >= 5) {
        brush_width-=pixelSize;
        custom_canvas.updateBrushWidth(brush_width);
      }
    } else if(get_mouse_scroll_up(0)) {
      brush_width+=pixelSize;
      custom_canvas.updateBrushWidth(brush_width);
    }
  }

  void update_ui() {
    for(uint i = 0; i < color_buttons.size(); i++) {
      color_buttons[i].draw();
    }
    clear_button.draw();
    end_button.draw();
  }

  void draw(float sub_frame) {
    update_ui();
    float mouse_x = g.mouse_x_world(0, 18);
    float mouse_y = g.mouse_y_world(0, 18);
    custom_canvas.draw(mouse_x, 
                      mouse_y,  
                      cur_color);

    if(get_left_mouse_down(0)) {
      custom_canvas.addPixels(mouse_x, mouse_y);
    }

    if(right_mouse_down) {
      //Set the brush color to white while erasing
      if(cur_color != WHITE) {
        temp_color = cur_color;
        cur_color = WHITE;
      }
      custom_canvas.removePixels(mouse_x, mouse_y);
    } else {
      if(temp_color != WHITE) {
        cur_color = temp_color;
        temp_color = WHITE;
      }
    }
  }

  void editor_draw(float sub_frame) {
    //draw canvas and buttons
    update_ui();
    custom_canvas.drawCanvas();
  }

  void editor_step() {
    ui.step();
    init_buttons();
  }
  /*Helper methods*/
  bool get_left_mouse_down(int player) {
    return (g.mouse_state(player) & 0x04) == 0x04;
  }

  bool get_right_mouse_down(int player) {
    return (g.mouse_state(player) & 0x08) == 0x08;
  }

  bool get_mouse_scroll_down(int player) {
    return (g.mouse_state(player) & 0x02) == 0x02;
  }

  bool get_mouse_scroll_up(int player) {
    return (g.mouse_state(player) & 0x01) == 0x01;
  }

  bool get_mouse_middle_down(int player) {
    return (g.mouse_state(player) & 0x10) == 0x10;
  }
}

/*
 * Class used to make each color selection button
 */
class ColorButton : ButtonClickHandler, callback_base {
  private float BUTTON_HEIGHT = 34;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ color_button;
  Mouse@ mouse;
  Rect border;
  uint col;

  ColorButton(UI@ ui, uint color, float X1, float Y1) {
    @g = get_scene();
    col = color;
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    const float height = BUTTON_HEIGHT - ui.padding * 2;
    @color_button = Button(ui, ColorSwab(ui, 5, color));
    color_button.fit_to_height(height);
    @color_button.click_listener = this;
  }

  void draw() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
      rect.x1 - PADDING - color_button.width, rect.y1,
      rect.x1 - PADDING, rect.y2);
    color_button.draw(g, rect);
  }

  void on_button_click(Button@ button) {
    message@ msg = create_message();
    msg.set_string('color_change', "true");
    msg.set_int('color', col);
    broadcast_message('color_picked', msg); 
  }
}