#include "../lib/math/Rect.cpp"
#include "../lib/ui/Button.cpp"
#include "../lib/ui/label.cpp"
#include "../lib/ui/UI.cpp"
#include '../lib/ui/shapes/Shape.cpp';
#include "../lib/math/math.cpp"

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
  bool right_mouse_down;
  [text]CustomCanvas custom_canvas;
  [text] float pixelSize;
  [position,mode:world,layer:18,y:bY1] float bX1;
  [hidden] float bY1;

  [position,mode:world,layer:18,y:cbY1] float cbX1;
  [hidden] float cbY1;

  [position,mode:world,layer:18,y:ebY1] float ebX1;
  [hidden] float ebY1;

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

  [hidden]ClearButton @clear_button;
  [hidden]EndButton @end_button;

  array<DrawingChunk@> drawing();
  uint code_index;

  script() {
    code_index = 0;
    @g = get_scene();
    brush_width = pixelSize;
    init_buttons();
    cur_color = BLACK;
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
      puts("clear");
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

    @clear_button  = ClearButton (ui, cbX1, cbY1);
    @end_button  = EndButton (ui, ebX1, cbY1);
  }

  void on_checkpoint_load() {

  }

  void build_sounds(message@ msg) {
    msg.set_string("ss", "sound1");
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

     if(@controller_entity(0) == null)
      return;
     dustman@ dm = controller_entity(0).as_dustman();

     int player = 0;
     update_code(dm);

    //handle mouse inputs
     if(get_left_mouse_down(player)) {
       //Nothing yet
     } 

     if(get_right_mouse_down(player)) {
       right_mouse_down = true;
     } else {
       right_mouse_down = false;
     }

     if(get_mouse_scroll_down(player)) {
       if(brush_width > 5 && brush_width - pixelSize >= 5) {
        brush_width-=pixelSize;
       }
     }

     if(get_mouse_scroll_up(player)) {
       brush_width+=pixelSize;
     }

     if(get_mouse_middle_down(player)) {
       //idk something?
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
    clear_button.draw();
    end_button.draw();
  }

  void draw(float sub_frame) {
    float mouse_x = g.mouse_x_world(0, 18);
    float mouse_y = g.mouse_y_world(0, 18);

    update_ui();
    custom_canvas.update(g.mouse_x_world(0, 18), g.mouse_y_world(0, 18), brush_width, cur_color);
    uint player = 0;

    custom_canvas.draw(cur_color);

    if(get_left_mouse_down(player)) {
    custom_canvas.addPixels(mouse_x, mouse_y, brush_width);
    }

    if(right_mouse_down) {
      custom_canvas.removePixels(mouse_x, mouse_y, brush_width);
    }
  }

  void editor_draw(float sub_frame) {
    //draw canvas
    update_ui();
    custom_canvas.drawCanvas();
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

class ClearButton : ButtonClickHandler, callback_base {
  private float TITLE_BAR_HEIGHT = 34;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ clear_button;
  Mouse@ mouse;
  bool visible = true;
  Rect border;

  ClearButton(UI@ ui, float X1, float Y1) {
    @g = get_scene();
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    const float height = TITLE_BAR_HEIGHT - ui.padding * 2;
    @clear_button = Button(ui, Label(ui, 'Clear'));
    clear_button.fit_to_height(height);
    @clear_button.click_listener = this;
  }

  void draw() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
      rect.x1 - PADDING - clear_button.width, rect.y1,
      rect.x1 - PADDING, rect.y2);
    clear_button.draw(g, rect);
  }

  void show()
  {
    visible = true;
  }

  void on_button_click(Button@ button)
  {
    puts("clicked!");
    message@ msg = create_message();
    msg.set_string('clear_canvas', "true");
    broadcast_message('clear_canvas', msg); 
  }
}

class EndButton : ButtonClickHandler, callback_base {
  private float TITLE_BAR_HEIGHT = 34;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ end_button;
  Mouse@ mouse;
  bool visible = true;
  Rect border;

  EndButton(UI@ ui, float X1, float Y1) {
    @g = get_scene();
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    const float height = TITLE_BAR_HEIGHT - ui.padding * 2;
    @end_button = Button(ui, Label(ui, 'Done!'));
    end_button.fit_to_height(height);
    @end_button.click_listener = this;
  }

  void draw() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
      rect.x1 - PADDING - end_button.width, rect.y1,
      rect.x1 - PADDING, rect.y2);
    end_button.draw(g, rect);
  }

  void show()
  {
    visible = true;
  }

  void on_button_click(Button@ button)
  {
    puts("clicked!");
    message@ msg = create_message();
    msg.set_string('end_level', "true");
    broadcast_message('end_level', msg); 
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
     g.draw_rectangle_world(17, 20, rect.x1-w, rect.y1-w, rect.x2+w, rect.y2+w, 0, color);
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

class CustomCanvas {
  float x1, x2, y1, y2;
  array<array<DrawingChunk@>> pixels;

  //Be sure X1 Y1 are always top left
  [position,mode:world,layer:18,y:Y1] float X1;
  [hidden] float Y1;
  [position,mode:world,layer:18,y:Y2] float X2;
  [hidden] float Y2;
  [hidden] float height;
  [hidden] float width;
  [hidden] float pixelSize;
  [hidden] Rect brushRect;
  [hidden] uint cur_color;
  scene@ g;

  CustomCanvas() {
    @g = get_scene();
    pixelSize = 10;
    cur_color = WHITE;
    brushRect = Rect(0,0,0,0);
  }

  void init(float size) {
    //Update canvas resolution to fit pixels cleanly
    float temp = min(X1, X2);
    uint pixelWidth = uint((max(X1,X2) - temp) / pixelSize);
    X2 = temp + pixelWidth * pixelSize;
    X1 = temp;

    temp = min(Y1, Y2);
    uint pixelHeight = uint((max(Y1,Y2) - temp) / pixelSize);
    Y2 = temp + pixelHeight * pixelSize;
    Y1 = temp;
    puts(X1 + " " + Y1 + " " + X2 + " " + Y2);  
    height = abs(Y1 - Y2);
    width = abs(X1 - X2);

    puts("h: "+height+" w: "+width);
    pixelSize = size;
    puts("arr y: " + height/pixelSize + " arrx: "+ width/pixelSize);
    for(uint i = 0; i < uint(height); i += uint(pixelSize)) {
      pixels.insertLast(array<DrawingChunk@>(uint(width/pixelSize)));
    }
  }

  void drawCanvas() {
    g.draw_rectangle_world(17, 10, X1, Y1, X2, Y2, 0, WHITE);
  }

  void drawPixels(DrawingChunk chunk) {
    Rect r = chunk.rect;
  }

  void erasePixels(DrawingChunk chunk) {

  }

  void updatePixelSize(float size) {
    pixelSize = size;
  }

  void drawBrush() {
    g.draw_rectangle_world(17, 12,
      brushRect.x1,
      brushRect.y1,
      brushRect.x2,
      brushRect.y2,
      0, cur_color
  )   ;
  }

  void updateBrushPos(float mouse_x, float mouse_y, float brush_width, uint cur_color) {
    //Only draw if mouse is inside canvas
    if(insideCanvas(mouse_x, mouse_y, brush_width)) {
    uint relX = uint(abs(floor(mouse_x) - min(X1, X2)));
    uint relY = uint(abs(floor(mouse_y) - min(Y1, Y2)));
    
    float numPixelsHorz = floor(relX / pixelSize);
    float numPixelsVert = floor(relY / pixelSize);
    
    //Ensure brush stays inside canvas and goes away if mouse goes off
    float brushX1 = max(min(X1,X2) + (numPixelsHorz * pixelSize) - brush_width, min(X1, X2));
    float brushX2 = min(min(X1,X2) + (numPixelsHorz * pixelSize) + brush_width, max(X1, X2));
    float brushY1 = max(min(Y1,Y2) + (numPixelsVert * pixelSize) - brush_width, min(Y1, Y2));
    float brushY2 = min(min(Y1,Y2) + (numPixelsVert * pixelSize) + brush_width, max(Y1, Y2));
    brushRect.x1 = brushX1;
    brushRect.x2 = brushX2;
    brushRect.y1 = brushY1;
    brushRect.y2 = brushY2;
    } else {
    brushRect.x1 = 0;
    brushRect.x2 = 0;
    brushRect.y1 = 0;
    brushRect.y2 = 0;
    }
  }

  bool insideCanvas(float mouse_x, float mouse_y, float brush_width) {
    float mx = floor(mouse_x);
    float my = floor(mouse_y);
    //puts("br: "+br+" mx: "+mx+" my: "+my+" br: "+br+" X1: "+X1+" Y1: "+Y1+" X2: "+X2+" Y2: "+Y2);
    return (mx) <= max(X1, X2) && (mx) >= min(X1, X2) &&
         (my) <= max(Y1, Y2) && (my) >= min(Y1, Y2);
  }

  void update(float mouse_x, float mouse_y, float brush_width, uint cur_color) {
    updateBrushPos(mouse_x, mouse_y, brush_width, cur_color);
  }

  void draw(uint color) {
    cur_color = color;
    //Draw the White Canvas
    drawCanvas();
    
    //Draw the brush preview
    drawBrush();
    
    //Draw the pixels on the canvas
    drawPixels();
  }

  void addPixels(float mouse_x, float mouse_y, float brush_width) {
    //If we are using white, just make the pixels null to save on computation
    if(cur_color == WHITE) {
      removePixels(mouse_x, mouse_y, brush_width);
    } else if(insideCanvas(mouse_x, mouse_y, brush_width)) {
      puts("x1: "+brushRect.x1 +" x2: "+brushRect.x2);
      //Iterate over each pixel inside the brush rectangle
      for(float i = brushRect.y1; i < brushRect.y2; i += pixelSize) {
        for(float j = brushRect.x1; j < brushRect.x2; j += pixelSize) {
          //Determine the rect that bounds the pixel
          float pixelX1 = j;
          float pixelX2 = j + pixelSize;
          float pixelY1 = i;
          float pixelY2 = i + pixelSize;
          //puts("x1 "+pixelX1+" x2 "+pixelX2+" y1 "+pixelY1+" y2 "+pixelY2);
          DrawingChunk@ d = DrawingChunk(Rect(pixelX1, pixelY1, pixelX2, pixelY2), cur_color);

          float relX = abs(max(pixelX1, X1) - min(pixelX1, X1));
          float relY = abs(max(pixelY1, Y1) - min(pixelY1, Y1));

          uint index_i = uint(floor(relY/pixelSize));
          uint index_j = uint(floor(relX/pixelSize));
          //puts("i: "+index_i+" j: "+index_j);
          pixels[index_i].removeAt(index_j);
          pixels[index_i].insertAt(index_j, d);
        }
      }
    }
  }

  void removePixels(float mouse_x, float mouse_y, float brush_width) {
    if(insideCanvas(mouse_x, mouse_y, brush_width)) {
      puts("x1: "+brushRect.x1 +" x2: "+brushRect.x2);
      //Iterate over each pixel inside the brush rectangle
      for(float i = brushRect.y1; i < brushRect.y2; i += pixelSize) {
        for(float j = brushRect.x1; j < brushRect.x2; j += pixelSize) {
          //Determine the rect that bounds the pixel
          float pixelX1 = j;
          float pixelY1 = i;

          float relX = abs(max(pixelX1, X1) - min(pixelX1, X1));
          float relY = abs(max(pixelY1, Y1) - min(pixelY1, Y1));
          uint index_i = uint(floor(relY/pixelSize));
          uint index_j = uint(floor(relX/pixelSize));
          pixels[index_i].removeAt(index_j);
          pixels[index_i].insertAt(index_j, null);
        }
      }
    }
  }

  void drawPixels() {
    for(uint i = 0; i < pixels.size(); i++) {
      for(uint j = 0; j < pixels[i].size(); j++) {
        if(@pixels[i][j] != null) {
          g.draw_rectangle_world(17, 11,
          pixels[i][j].rect.x1,
          pixels[i][j].rect.y1,
          pixels[i][j].rect.x2,
          pixels[i][j].rect.y2,
          0, pixels[i][j].color
          );
        }
      }
    }
  }
}

