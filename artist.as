#include "../lib/math/Rect.cpp"
#include "../lib/ui/Button.cpp"
#include "../lib/ui/label.cpp"
#include "../lib/ui/UI.cpp"
#include '../lib/ui/shapes/Shape.cpp';

const uint WHITE = 0xFFFFFFFF;
const uint BLACK = 0xFF000000;
const uint YELLOW = 0xFFDFFF00;
const uint ORANGE = 0xFFFFBF00;
const uint RED = 0xFFFF7F50;
const uint PINK = 0xFFDE3163;
const uint DARK_GREEN = 0xFF9FE2BF;
const uint GREEN = 0xFF7CFC00;
const uint BLUE = 0xFF6495ED;
const uint PURPLE = 0xFFC3B1E1;

const float BUTTON_SPACING = 20;

class script : callback_base{
    scene@ g;
    UI@ ui = UI();
    Mouse@ mouse = ui.mouse;
    uint cur_color;

    [position,mode:world,layer:18,y:Y1] float X1;
    [hidden] float Y1;
    [position,mode:world,layer:18,y:Y2] float X2;
    [hidden] float Y2;
    [position,mode:world,layer:18,y:bY1] float bX1;
    [hidden] float bY1;

    [text] float brush_width;

    //TODO: make into array of buttons idk im dumb with ui
    [hidden]ColorButton @color_button;
    [hidden]ColorButton @color_button1;
    [hidden]ColorButton @color_button2;
    [hidden]ColorButton @color_button3;
    [hidden]ColorButton @color_button4;
    [hidden]ColorButton @color_button5;
    [hidden]ColorButton @color_button6;
    [hidden]ColorButton @color_button7;
    [hidden]ColorButton @color_button8;
    [hidden]ColorButton @color_button9;

    array<DrawingChunk@> drawing();
    uint code_index;

    script() {
        code_index = 0;
        @g = get_scene();
        brush_width = 10;
        init_buttons();
        cur_color = BLACK;
        add_broadcast_receiver('color_picked', this, 'update_color');
        //bX1 = 0;
        //bY1 = 0;
    }

    void update_color(string id, message@ msg) {
        if(msg.get_string('color_change') == 'true') {  
            cur_color = msg.get_int("color");
        }
    }

    void on_level_start() {
        init_buttons();
    }
// const uint WHITE = 0xFFFFFFFF;
// const uint BLACK = 0xFF000000;
// const uint YELLOW = 0xFFDFFF00;
// const uint ORANGE = 0xFFFFBF00;
// const uint RED = 0xFFFF7F50;
// const uint PINK = 0xFFDE3163;
// const uint DARK_GREEN = 0xFF9FE2BF;
// const uint GREEN = 0xFF7CFC00;
// const uint BLUE = 0xFF6495ED;
    void init_buttons() {
        @color_button  = ColorButton (ui, WHITE, bX1, bY1);
        @color_button1 = ColorButton(ui, BLACK, bX1 + BUTTON_SPACING + ui.padding, bY1);
        @color_button2 = ColorButton(ui, YELLOW, bX1 + (BUTTON_SPACING*2) + ui.padding*2, bY1);
        @color_button3 = ColorButton(ui, ORANGE, bX1 + (BUTTON_SPACING*3) + ui.padding*3, bY1);
        @color_button4 = ColorButton(ui, RED, bX1 + (BUTTON_SPACING*4) + ui.padding*4, bY1);
        @color_button5 = ColorButton(ui, PINK, bX1 + (BUTTON_SPACING*5) + ui.padding*5, bY1);
        @color_button6 = ColorButton(ui, DARK_GREEN, bX1 + (BUTTON_SPACING*6) + ui.padding*6, bY1);
        @color_button7 = ColorButton(ui, GREEN, bX1 + (BUTTON_SPACING*7) + ui.padding*7, bY1);
        @color_button8 = ColorButton(ui, BLUE, bX1 + (BUTTON_SPACING*8) + ui.padding*8, bY1);
        @color_button9 = ColorButton(ui, PURPLE, bX1 + (BUTTON_SPACING*9) + ui.padding*9, bY1);
    }

    void on_checkpoint_load() {

    }

    void build_sounds(message@ msg) {
        msg.set_string("ss", "sound1");
    }

    //taunt, light, heavy, light, dash, dash, taunt
    void update_code(dustman@ dm) {
        //puts("index: "+code_index);
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
       if(@controller_entity(0) == null)
          return;
       dustman@ dm = controller_entity(0).as_dustman();

       int player = 0;
       update_code(dm);

      //handle mouse inputs
       if(get_left_mouse_down(player)) {

       } 

       if(get_right_mouse_down(player)) {
           
       }

       if(get_mouse_scroll_down(player)) {
           brush_width--;
       }

       if(get_mouse_scroll_up(player)) {
           brush_width++;
       }

       if(get_mouse_middle_down(player)) {
           //Change color

       }
    }

    void update_ui() {
        color_button.draw();
        color_button1.draw();
        color_button2.draw();
        color_button3.draw();
        color_button4.draw();
        color_button5.draw();
        color_button6.draw();
        color_button7.draw();
        color_button8.draw();
        color_button9.draw();
    }

    void draw(float sub_frame) {
      update_ui();
      float mouse_x = g.mouse_x_world(0, 18);
      float mouse_y = g.mouse_y_world(0, 18);
      uint player = 0;
      //draw Canvas
      g.draw_rectangle_world(18, 10, X1, Y1, X2, Y2, 0, WHITE);
      g.draw_rectangle_world(18, 11, 
      mouse_x + brush_width, 
      mouse_y + brush_width, 
      mouse_x - brush_width, 
      mouse_y - brush_width, 
      0, cur_color);

     if(get_left_mouse_down(player)) {
            float x1 = mouse_x + brush_width;
            float x2 = mouse_x - brush_width;
            float y1 = mouse_y + brush_width;
            float y2 = mouse_y - brush_width;

            Rect r = Rect(x1, y1, x2, y2);
            
            drawing.insertLast(DrawingChunk(r, cur_color));
      }

      for(uint i = 0; i < drawing.size(); i++) {
        Rect r = drawing[i].rect;
        //Determine if we should erase
        if(get_right_mouse_down(player)) {
            float minx = r.x1 < r.x2 ? r.x1 : r.x2;
            float maxx = r.x1 > r.x2 ? r.x1 : r.x2;
            float miny = r.y1 < r.y2 ? r.y1 : r.y2;
            float maxy = r.y1 > r.y2 ? r.y1 : r.y2;
            //Verify mouse is inside a square
            if(mouse_x > minx - brush_width && mouse_x < maxx + brush_width && 
               mouse_y > miny - brush_width && mouse_y < maxy + brush_width) {
                   drawing.removeAt(i);
               }
        }

        if(i < drawing.size()) {
            //Draw picture
            g.draw_rectangle_world(18, 10,
            r.x1,
            r.y1,
            r.x2,
            r.y2,
            0, drawing[i].color);
        }
      }
    }

    void editor_draw(float sub_frame) {
      //draw canvas
      update_ui();
      g.draw_rectangle_world(18, 10, X1, Y1, X2, Y2, 0, WHITE);
    }

    void editor_step() {
        ui.step();
        init_buttons();
    }
  /* Returns the mouse state for the given player as a bitmask. The
     bits correspond to the following button states:

     1: wheel up
     2: wheel down
     4: left click
     8: right click
     16: middle click
   */
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

class ColorButton : ButtonClickHandler, callback_base {
    private float TITLE_BAR_HEIGHT = 34;
    private float SIZE = 10;
    //Button
    UI@ ui;
    scene@ g;
    Button@ color_button;
    Mouse@ mouse;
    bool visible = true;
    Rect border;
    uint col;

    ColorButton(UI@ ui, uint color, float X1, float Y1) {
        @g = get_scene();
        col = color;
        @this.ui = ui;
        @this.mouse = ui.mouse;
        border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
        const float height = TITLE_BAR_HEIGHT - ui.padding * 2;
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

    void show()
    {
        visible = true;
    }

    void on_button_click(Button@ button)
    {
        puts("clicked!");
        message@ msg = create_message();
        msg.set_string('color_change', "true");
        msg.set_int('color', col);
        broadcast_message('color_picked', msg); 
    }
}

class ColorSwab : Shape
{
    float thickness;
    uint color;
    ColorSwab(UI@ ui, float thickness = 3, uint color = 0xCCFFFFFF)
    {
        super(ui, color);
        this.color = color;
        this.thickness = thickness;
    }

    void draw(scene@ g, Rect rect)
    {
         float centre_x = rect.centre_x;
         float centre_y = rect.centre_y;
         float w = thickness * 0.5;
         //TODO layer?
         g.draw_rectangle_world(19, 19, rect.x1-w, rect.y1-w, rect.x2+w, rect.y2+w, 0, color);
    }

}

class DrawingChunk {
    Rect rect;
    uint color;

    DrawingChunk(Rect r, uint c) {
        rect = r;
        color = c;
    }

}
