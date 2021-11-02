#include "../lib/math/Rect.cpp"
#include "../lib/ui/Button.cpp"
#include "../lib/ui/label.cpp"
#include "../lib/ui/UI.cpp"

#include "../lib/math/math.cpp"

#include "jlib/const/ColorConsts.as"
#include "jlib/ui/CustomCanvas.as"
#include "jlib/ui/ColorSwab.as"
#include "jlib/ui/LabelButton.as"

const string EMBED_filtered = "artist/filtered.ogg";
const string EMBED_main = "artist/main.ogg";
const string EMBED_splash = "artist/splash.ogg";
const string EMBED_draw = "artist/draw.ogg";
const string EMBED_erase = "artist/erase.ogg";
const string EMBED_arp = "artist/arp.ogg";
const string EMBED_arp_filtered = "artist/arp_filtered.ogg";

const float BUTTON_SPACING = 28;
const uint NUM_COLOR_BUTTONS = 48;

class script : callback_base{
  scene@ g;
  UI@ ui = UI();
  Mouse@ mouse = ui.mouse;

  uint cur_color;
  uint temp_color;
  entity@ totem;
  bool right_mouse_down;
  [hidden] uint numPlayers;
  [text] uint framerate;
  [text]CustomCanvas custom_canvas;
  CustomCanvas@ cur_canvas;
  array<CustomCanvas@> custom_canvases;
  [hidden]uint curCanvas;
  [text] float pixelSize;
  [position,mode:world,layer:18,y:bY1] float bX1;
  [hidden] float bY1;
  [position,mode:world,layer:18,y:cbY1] float cbX1;
  [hidden] float cbY1;
  [position,mode:world,layer:18,y:ebY1] float ebX1;
  [hidden] float ebY1;
  [position,mode:world,layer:18,y:fbY1] float fbX1;
  [hidden] float fbY1;
  [position,mode:world,layer:18,y:pbY1] float pbX1;
  [hidden] float pbY1;
  [text] float brush_width;
  [hidden] array<ColorButton@> color_buttons(NUM_COLOR_BUTTONS);
  array<FrameButton@> frame_buttons(2);
  [hidden]LabelButton @clear_button;
  [hidden]LabelButton @end_button;
  [hidden]LabelButton @play_button;
  [entity] int apple;
  [hidden] bool appleSpawned;
  [hidden] bool levelEnded;
  //max volume of rest_song
  [hidden] float rest_song_vol;
  //max volume of filtered song
  [hidden] float filtered_song_vol;
  //max volume of main song
  [hidden] float main_song_vol;
  //max volume of arp song
  [hidden] float arp_song_vol;
  //max volume of arp song filtered
  [hidden] float arp_song_filtered_vol;
  //bool to dennote if we should be fading in or out the song
  [hidden] bool isDrawing = false;
  //speed we should fade the song in/out
  [text] int fadeSpeed;
  //frame counter for current fade
  [hidden] int currentFade;
  [hidden] int currentFadeMain;
  [hidden] int currentFadeFiltered;
  [hidden] int currentFadeArp;
  [hidden] int currentFadeArpFiltered;
  [hidden] bool leftMousePressed;
  [hidden] bool middle_mouse_down;
  [hidden] bool filling;

  bool animate;
  uint frame;
  uint animationFrame;
  audio@ filtered_song;
  audio@ rest_song;
  audio@ main_song;
  audio@ arp_song;
  audio@ arp_song_filtered;

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
    add_broadcast_receiver('add_canvas', this, 'add_canvas');
    add_broadcast_receiver('remove_canvas', this, 'remove_canvas');
    add_broadcast_receiver('set_canvas_index', this, 'set_canvas_index');
    add_broadcast_receiver('play_animation', this, 'play_animation');
    
    right_mouse_down = false;
    appleSpawned = false;
    fadeSpeed = 100;
    currentFade = 0;
    currentFadeFiltered = 0;
    currentFadeMain = 0;
    rest_song_vol = .50;
    filtered_song_vol = .75;
    main_song_vol = .75;
    arp_song_vol = .50;
    arp_song_filtered_vol = .75;
    levelEnded = false;
    leftMousePressed = false;
    middle_mouse_down = false;
    filling = false;
    curCanvas = 0;
    animate = false;
    frame = 0;
    animationFrame = 0;
    framerate = 10;
  }

  void update_color(string id, message@ msg) {
    if(msg.get_string('color_change') == 'true') {  
      cur_color = msg.get_int("color");
    }

    highlight_selected_button();
  }

  void highlight_selected_button() {
    for(uint i = 0; i < color_buttons.size(); i++) {
      color_buttons[i].selected = color_buttons[i].col == cur_color;
    }
  }

  void clear_canvas(string id, message@ msg) {
    if(msg.get_string('clear_canvas') == 'true' && !levelEnded) {  
      //Clear canvas
      dustman@ dm = controller_entity(0).as_dustman();

      //Spawn large totem above dustman in attacking state and add to scene
      @totem = create_entity("enemy_stoneboss");
      totem.as_controllable().scale(5, false);
      totem.set_xy(dm.x(), dm.y()-200);
      totem.as_controllable().attack_state(1);
      g.add_entity(totem);
    }
  }
  
  void end_level(string id, message@ msg) {
    if(msg.get_string('end_level') == 'true' && !levelEnded) { 
      cur_canvas.disableDrawing();
      g.end_level(0,0);
      levelEnded = true;
    }
  } 

  void add_canvas(string id, message@ msg) {
    addCanvas(frame_buttons.size()-2);
    if(frame_buttons.size() > 0) {
      //Get previous button's rect
      Rect r = frame_buttons[frame_buttons.size()-1].border;

      float x1 = r.x1;
      float y1 = r.y1 + (BUTTON_SPACING + ui.padding);

      frame_buttons.insertLast(FrameButton(ui, x1, y1, frame_buttons.size() - 2, false));
    }
    updateDeadAreas();
  }

  void remove_canvas(string id, message@ msg) {
    //Only remove canvas if there is more than 1
    puts("remove "+custom_canvases.size());
    if(custom_canvases.size() > 1) {
      removeCanvas(curCanvas);

      for(uint i = frame_buttons.size()-1; i > curCanvas + 1; i--) {
        Rect r = frame_buttons[i-1].border;
        frame_buttons[i].border = r;
        //Subtract one off the label
        uint label = parseUInt(cast<Label>(frame_buttons[i].frame_button.icon).text);
        cast<Label>(frame_buttons[i].frame_button.icon).text = (label - 1) + "";

        //The index should match the new label we are setting the button as
        frame_buttons[i].frame_index = label - 1;
      }

      curCanvas = curCanvas > 0 ? curCanvas - 1 : 0;
      //remove button
      frame_buttons.removeAt(curCanvas+2);
      updateDeadAreas();

      changeCanvas(curCanvas);
    }
  }

  void play_animation(string id, message@ msg) {
    animate = !animate;
  }

  void set_canvas_index(string id, message@ msg) {
    changeCanvas(msg.get_int("index"));
  }

  
  void changeCanvas(uint idx) {
    if(idx < custom_canvases.size()) {
      puts("change");
      curCanvas = idx;
      //Save current brush size to pass to new canvas
      float bw = cur_canvas.brush_width;
      @cur_canvas = custom_canvases[idx];

      //Set new canvas brush size
      cur_canvas.brush_width = bw;

      for(uint i = 2; i < frame_buttons.size(); i++) {
        //Reset all button's preview attribute to false
        frame_buttons[i].preview = false;

        if(frame_buttons[i].frame_index == curCanvas) {
          //Highlight selected frame
          Rect r = frame_buttons[i].border;
          r.x1 += (BUTTON_SPACING + ui.padding);
          frame_buttons[1].border = r;
          frame_buttons[i].selected = true;
          if(i > 2 && !animate) {
            //Have preview transperency on previous frame
            frame_buttons[i - 1].preview = true;
            frame_buttons[i - 1].selected = true;
          }
        }
        frame_buttons[i].selected = frame_buttons[i].frame_index == curCanvas;
      }
    }
  }

  void updateDeadAreas() {
    for(uint i = 0; i < custom_canvases.size(); i++) {
      Rect r = frame_buttons[0].getButtonRect();
      custom_canvases[i].setDeadArea(Rect(r.x1-2, r.y1, r.x2, abs(r.y2 - r.y1)*frame_buttons.size()));
    }
  }

  void addCanvas(uint idx) {
    CustomCanvas@ c = CustomCanvas(custom_canvas.X1, custom_canvas.Y1, custom_canvas.X2, custom_canvas.Y2);

    c.init(pixelSize);
    //Dont allow drawing when pressing other buttons
    c.setDeadArea(Rect(bX1-(BUTTON_SPACING + ui.padding)-2, bY1, (bX1+(BUTTON_SPACING + ui.padding) * 15) - 6, (bY1+(BUTTON_SPACING + ui.padding)*3) - 4));
    c.setDeadArea(clear_button.getRect());
    c.setDeadArea(end_button.getRect());
    c.setDeadArea(play_button.getRect());

    custom_canvases.insertAt(idx, c);
  }

  void removeCanvas(uint idx) {
    if(idx < custom_canvases.size()) {
      custom_canvases.removeAt(idx);
    }
  }

  void on_level_start() {
    custom_canvases.insertLast(custom_canvas);
    init_buttons();
    custom_canvases[0].init(pixelSize);

    //Dont allow drawing when pressing other buttons
    custom_canvases[0].setDeadArea(Rect(bX1-(BUTTON_SPACING + ui.padding)-2, bY1, (bX1+(BUTTON_SPACING + ui.padding) * 15) - 6, (bY1+(BUTTON_SPACING + ui.padding)*3) - 4));
    custom_canvases[0].setDeadArea(clear_button.getRect());
    custom_canvases[0].setDeadArea(end_button.getRect());
    custom_canvases[0].setDeadArea(play_button.getRect());
    
    @cur_canvas = custom_canvases[0];
    
    if(frame_buttons.size() > 0) {
      //Get previous button's rect
      Rect r = frame_buttons[frame_buttons.size()-2].border;

      float x1 = r.x1;
      float y1 = r.y1 + (BUTTON_SPACING + ui.padding);

      frame_buttons.insertLast(FrameButton(ui, x1, y1, frame_buttons.size() - 2, false));
    }
    
    highlight_selected_button();
    isDrawing = false;
    levelEnded = false;
    //Get previous persistent stream handles in case level was restarted to handle fading correctly
    audio@ m = g.get_persistent_stream('main');
    audio@ f = g.get_persistent_stream('filtered');
    audio@ r = g.get_persistent_stream('arp');
    audio@ rf = g.get_persistent_stream('arp_filtered');
    if(@m != null) {
      @main_song = m;
      main_song.volume(0);
    } else {
      @main_song = g.play_persistent_stream('main', 1, true, 0, true);
    }

    if(@f != null) {
      @filtered_song = f;
      filtered_song.volume(filtered_song_vol);
    } else {
      @filtered_song = g.play_persistent_stream('filtered', 1, true, filtered_song_vol, true);
    }

    if(@r != null) {
      @arp_song = r;
      arp_song.volume(0);
    } else {
      @arp_song = g.play_persistent_stream('arp', 1, true, 0, true);
    }

    if(@rf != null) {
      @arp_song_filtered = rf;
      arp_song_filtered.volume(0);
    } else {
      @arp_song_filtered = g.play_persistent_stream('arp_filtered', 1, true, 0, true);
    }
    updateDeadAreas();
  }

  void init_buttons() {
    @frame_buttons[0] = FrameButton(ui, fbX1, fbY1, 0, true);
    @frame_buttons[1] = FrameButton(ui, fbX1 + BUTTON_SPACING + ui.padding, fbY1, 0, false, true);
    for(uint i = 0; i < color_buttons.size(); i++) {
      //Set up each color button. Each row of colors is 16 long
      @color_buttons[i] = ColorButton(ui, COLOR_LIST[i], 
      bX1 + (BUTTON_SPACING + ui.padding) * (i % 16), 
      bY1 + (BUTTON_SPACING + ui.padding) * (i/16));
    }
    @play_button = LabelButton(ui, pbX1, pbY1, "play_animation", "Play!");
    @clear_button  = LabelButton(ui, cbX1, cbY1, "clear_canvas", "Clear");
    @end_button  = LabelButton(ui, ebX1, cbY1, "end_level", "Done!");
  }

  void build_sounds(message@ msg) {
    msg.set_string("filtered", "filtered");
    msg.set_int("filtered|loop", 59535);

    msg.set_string("main", "main");
    msg.set_int("main|loop", 59535);

    msg.set_string("arp", "arp");
    msg.set_int("arp|loop", 59535);

    msg.set_string("arp_filtered", "arp_filtered");
    msg.set_int("arp_filtered|loop", 59535);

    msg.set_string("splash", "splash");
    msg.set_string("draw", "draw");
    msg.set_string("erase", "erase");
  }



  void step(int) {
    dustman@ dm;
    if(@controller_entity(0) != null)
      @dm = controller_entity(0).as_dustman();
    else
      return;
    step_ui();

    float mouse_x = g.mouse_x_world(0, 18);
    float mouse_y = g.mouse_y_world(0, 18);
    
    cur_canvas.step(mouse_x, mouse_y, cur_color);
    ui.step();

    cur_canvas.updatePixelSize(pixelSize);

    dm.skill_combo(cur_canvas.getNumColors() * 13);
    g.combo_break_count(8 - cur_canvas.getNumColors());

    //SS Condition
    if(cur_canvas.getNumColors() >= 8) {
      g.combo_break_count(0);
      if(isDrawing || levelEnded) {
        fadeInArp();
        fadeOutMain();
        fadeOutFiltered();
        fadeOutArpFiltered();
      } else {
        fadeInArpFiltered();
        fadeOutMain();
        fadeOutFiltered();
        fadeOutArp();
      }
    } else { //No SS Condition
      if(isDrawing || levelEnded) {
        fadeInMain();
        fadeOutFiltered();
        fadeOutArpFiltered();
        fadeOutArp();
      } else {
        fadeInFiltered();
        fadeOutMain();
        fadeOutArp();
        fadeOutArpFiltered();
      }
    }

    if(@totem != null && 
       totem.as_controllable().life() <= 0 &&
       @entity_by_id(apple) != null &&
       !appleSpawned) {
      
      entity_by_id(apple).set_xy(dm.x(), dm.y() - 400);
      appleSpawned = true;
    }
    if(@controller_entity(0) == null) {
      return;
    }
    
    //handle mouse inputs
    right_mouse_down = get_right_mouse_down(0);
    leftMousePressed = get_left_mouse_down(0);
    middle_mouse_down = get_mouse_middle_down(0);

    if(get_mouse_scroll_down(0)) {
      if(brush_width >= pixelSize && brush_width - pixelSize >= 5) {
        brush_width-=pixelSize;
        cur_canvas.updateBrushWidth(brush_width);
      }
    } else if(get_mouse_scroll_up(0)) {
      if(brush_width < max(cur_canvas.width, cur_canvas.height)){
        brush_width+=pixelSize;
        cur_canvas.updateBrushWidth(brush_width);
      }
    }

    if(leftMousePressed) {
      // Fade in if we are drawing
      isDrawing = cur_canvas.addPixels();
    } else {
      isDrawing = false;
    } 
    
    if(right_mouse_down) {
      //Set the brush color to white while erasing
      if(cur_color != WHITE) {
        temp_color = cur_color;
        cur_color = WHITE;
      }
      // Fade in if we are erasing
      isDrawing = cur_canvas.removePixels();
    } else {
        if(temp_color != WHITE) {
          cur_color = temp_color;
          temp_color = WHITE;
          isDrawing = false;
        }
    } 
    
    if (middle_mouse_down) {
      if(!filling) {
        filling = true;
        cur_canvas.fill(@cur_canvas.cur_pixel);
      }
    } else {
      filling = false;
    }



    if(cur_canvas.drewLastFrame) {
      g.play_script_stream("draw", 2, 0, 0, false, .85);
    } 
    
    if(cur_canvas.erasedLastFrame) {
      audio@ a = g.play_script_stream("erase", 2, 0, 0, false, 1);
      a.time_scale(.65);
    }

    //Animate
    if(animate) {
      if(frame % framerate == 0) {
        changeCanvas(animationFrame % custom_canvases.size());
        animationFrame++;
      }
    } else {
      if(animationFrame != 0) {
        //Change canvas to the current canvas to refresh highlighting on buttons
        changeCanvas(curCanvas);
      }
      animationFrame = 0;
      frame = 0;
    }
    frame++;
  }

  void draw_ui() {
    for(uint i = 0; i < color_buttons.size(); i++) {
      color_buttons[i].draw();
    }

    clear_button.draw();
    end_button.draw();
    play_button.draw();
    for(uint i = 0; i < frame_buttons.size(); i++) {
      frame_buttons[i].draw();
    }
  }

  void step_ui() {
    for(uint i = 0; i < color_buttons.size(); i++) {
      color_buttons[i].step();
    }

    for(uint i = 0; i < frame_buttons.size(); i++) {
      frame_buttons[i].step();
    }
    clear_button.step();
    end_button.step();
    play_button.step();
  }

  void draw(float sub_frame) {
    draw_ui();
    cur_canvas.draw();
    if(curCanvas > 0 && !animate) {
      custom_canvases[curCanvas-1].drawPreview();
    }
  }

  void editor_draw(float sub_frame) {
    //draw canvas and buttons
    draw_ui();
    custom_canvas.drawCanvas(false);
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
  
  void fadeInArp() {
    if(currentFadeArp <= fadeSpeed) {
      float t1 = currentFadeArp;
      float t2 = fadeSpeed;

      //volume is % of current fade
      arp_song.volume(divide(t1, t2) * arp_song_vol);

      currentFadeArp++;
    }
  }
  
  void fadeOutArp() {
     if(arp_song.volume() < 0.4) {
       arp_song.volume(0);
     }
     if(currentFadeArp > 0) {
      float t1 = currentFadeArp;
      float t2 = fadeSpeed;

      //volume is % of current fade
      arp_song.volume(divide(t1, t2) * arp_song_vol);

      currentFadeArp--;
    }
  }

  void fadeInArpFiltered() {
    if(currentFadeArpFiltered <= fadeSpeed) {
      float t1 = currentFadeArpFiltered;
      float t2 = fadeSpeed;

      //volume is % of current fade
      arp_song_filtered.volume(divide(t1, t2) * arp_song_filtered_vol);

      currentFadeArpFiltered++;
    }
  }
  
  void fadeOutArpFiltered() {
    if(arp_song_filtered.volume() < 0.4) {
       arp_song_filtered.volume(0);
     }
     if(currentFadeArpFiltered > 0) {
      float t1 = currentFadeArpFiltered;
      float t2 = fadeSpeed;

      //volume is % of current fade
      arp_song_filtered.volume(divide(t1, t2) * arp_song_filtered_vol);

      currentFadeArpFiltered--;
    }
  }

  void fadeOutMain() {
    if(@main_song == null) {
      return;
    }

    if(main_song.volume() < 0.4) {
       main_song.volume(0);
    }

    if(currentFadeMain > 0) {
      float t1 = currentFadeMain;
      float t2 = fadeSpeed;

      //volume is % of current fade
      main_song.volume(divide(t1, t2) * main_song_vol);

      currentFadeMain--;
    }
  }

  void fadeInMain() {
    if(currentFadeMain <= fadeSpeed) {
      float t1 = currentFadeMain;
      float t2 = fadeSpeed;

      //volume is % of current fade
      main_song.volume(divide(t1, t2) * main_song_vol);

      currentFadeMain++;
    }
  }

  void fadeInFiltered() {
    if(currentFadeFiltered <= fadeSpeed) {
      float t1 = currentFadeFiltered;
      float t2 = fadeSpeed;

      //volume is % of current fade
      filtered_song.volume(divide(t1, t2) * filtered_song_vol);

      currentFadeFiltered++;
    }
  }

  void fadeOutFiltered() {
     if(filtered_song.volume() < 0.4) {
       filtered_song.volume(0);
     }

     if(currentFadeFiltered > 0) {
      float t1 = currentFadeFiltered;
      float t2 = fadeSpeed;

      //volume is % of current fade
      filtered_song.volume(divide(t1, t2) * filtered_song_vol);

      currentFadeFiltered--;
    }
  }

  float divide(float f1, float f2) {
    return f1/f2 < 0.06 ? 0 : f1/f2;
  }
}

/*
 * Class used to make each color selection button
 */
class ColorButton : ButtonClickHandler, callback_base {
  private float BUTTON_HEIGHT = 40;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ color_button;
  Mouse@ mouse;
  Rect border;
  uint col;
  float height;
  bool selected;

  ColorButton(UI@ ui, uint color, float X1, float Y1) {
    @g = get_scene();
    col = color;
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    height = BUTTON_HEIGHT - ui.padding * 2;
    @color_button = Button(ui, ColorSwab(ui, 5, color));
    color_button.fit_to_height(height);
    @color_button.click_listener = this;
    selected = false;
  }

  void draw() {
    Rect rect = getButtonRect();
    //If the current button is selected, we want to highlight it
    if(selected) {
      highlight_button(rect);
    }

    color_button.draw(g, rect);
  }

  void step() {
    color_button.update(g, getButtonRect());
  }

  Rect getButtonRect() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
    rect.x1 - PADDING - color_button.width, rect.y1,
    rect.x1 - PADDING, rect.y2+height/2);

    return rect;
  }

  //Draws highlight on button. Used only for if script wants to 
  //Explicitly highlight button (on hover and on click are handled in button class)
  void highlight_button(Rect rect) {                            //magic sorry
    g.draw_rectangle_world(17, 20, rect.x1, rect.y1, rect.x2, rect.y2+5, 0, 0xFFCC483c);
    g.draw_rectangle_world(17, 21, rect.x1, rect.y1 + color_button.width, rect.x2 - color_button.width/2, (rect.y2+5) - color_button.width/2, 0, 0xFFCC483c);
  }


  void on_button_click(Button@ button) {
    message@ msg = create_message();
    msg.set_string('color_change', "true");
    msg.set_int('color', col);
    broadcast_message('color_picked', msg); 
    g.play_script_stream("splash", 2, 0, 0, false, 10);
  }
}


/*
 * Class used to make each color selection button
 */
class FrameButton : ButtonClickHandler, callback_base {
  private float BUTTON_HEIGHT = 40;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ frame_button;
  Mouse@ mouse;
  Rect border;
  float height;
  bool selected;
  uint frame_index;
  bool add_canvas;
  bool remove_canvas;
  bool preview;

  FrameButton(UI@ ui, float X1, float Y1, uint idx = 0, bool addCanvas = false, bool removeCanvas = false) {
    @g = get_scene();
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    height = BUTTON_HEIGHT - ui.padding * 2;
    if(addCanvas) {
      @frame_button = Button(ui, Label(ui, "+", false));
    } else if(removeCanvas) {
      @frame_button = Button(ui, Label(ui, "-", false));
    } else {
      @frame_button = Button(ui, Label(ui, idx+"", false));
    }
    frame_button.fit_to_height(height);
    @frame_button.click_listener = this;
    selected = false;
    frame_index = idx;
    add_canvas = addCanvas;
    remove_canvas = removeCanvas;
    preview = false;
  }

  void draw() {
    Rect rect = getButtonRect();
    //If the current button is selected, we want to highlight it
    if(selected) {
      highlight_button(rect);
    }

    frame_button.draw(g, rect);
  }

  void step() {
    frame_button.update(g, getButtonRect());
  }

  Rect getButtonRect() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
    rect.x1 - PADDING - frame_button.width, rect.y1,
    rect.x1 - PADDING, rect.y2+height/2);

    return rect;
  }

  //Draws highlight on button. Used only for if script wants to 
  //Explicitly highlight button (on hover and on click are handled in button class)
  void highlight_button(Rect rect) {                            //magic sorry
    g.draw_rectangle_world(17, 19, rect.x1, 
    rect.y1, rect.x2, rect.y2+5, 0, preview ? TRANSPARENCY | (0x00FFFFFF & 0xFFCC483c) : 0xFFCC483c);
  }


  void on_button_click(Button@ button) {
    if(add_canvas) {
      message@ msg = create_message();
      msg.set_string('add_canvas', "true");
      broadcast_message('add_canvas', msg); 
      //TODO: add sound effect?
      g.play_script_stream("splash", 2, 0, 0, false, 10);
    } else if(remove_canvas) {
      message@ msg = create_message();
      msg.set_string('remove_canvas', "true");
      broadcast_message('remove_canvas', msg); 
      //TODO: add sound effect?
      g.play_script_stream("splash", 2, 0, 0, false, 10);
    } else {
      message@ msg = create_message();
      msg.set_string('set_canvas_index', "true");
      msg.set_int('index', frame_index);
      broadcast_message('set_canvas_index', msg); 
      //TODO: add sound effect?
      g.play_script_stream("splash", 2, 0, 0, false, 10);
    }
  }
}
