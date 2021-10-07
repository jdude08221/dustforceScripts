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

const float BUTTON_SPACING = 20;
const uint NUM_COLOR_BUTTONS = 32;

class script : callback_base{
  scene@ g;
  UI@ ui = UI();
  Mouse@ mouse = ui.mouse;

  uint cur_color;
  uint temp_color;
  entity@ totem;
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
    right_mouse_down = false;
    appleSpawned = false;
    fadeSpeed = 100;
    currentFade = 0;
    currentFadeFiltered = 0;
    currentFadeMain = 0;
    rest_song_vol = .75;
    filtered_song_vol = .75;
    main_song_vol = .75;
    arp_song_vol = .75;
    arp_song_filtered_vol = .75;
    levelEnded = false;
  }

  void update_color(string id, message@ msg) {
    if(msg.get_string('color_change') == 'true') {  
      cur_color = msg.get_int("color");
    }
  }

  void clear_canvas(string id, message@ msg) {
    if(msg.get_string('clear_canvas') == 'true') {  
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
    if(msg.get_string('end_level') == 'true') { 
      custom_canvas.disableDrawing();
      g.end_level(0,0);
      levelEnded = true;
    }
  } 

  void on_level_start() {
    init_buttons();
    custom_canvas.init(pixelSize);
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
      puts("filtered");
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

    ui.step();
    custom_canvas.updatePixelSize(pixelSize);

    dm.skill_combo(custom_canvas.getNumColors() * 13);
    g.combo_break_count(8 - custom_canvas.getNumColors());

    //SS Condition
    if(custom_canvas.getNumColors() >= 8) {
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

    if(get_mouse_scroll_down(0)) {
      if(brush_width >= pixelSize && brush_width - pixelSize >= 5) {
        brush_width-=pixelSize;
        custom_canvas.updateBrushWidth(brush_width);
      }
    } else if(get_mouse_scroll_up(0)) {
      if(brush_width < max(custom_canvas.width, custom_canvas.height)){
        brush_width+=pixelSize;
        custom_canvas.updateBrushWidth(brush_width);
      }
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
      // Fade in if we are drawing
      isDrawing = custom_canvas.addPixels(mouse_x, mouse_y);
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
      isDrawing = custom_canvas.removePixels(mouse_x, mouse_y);
    } else {
        if(temp_color != WHITE) {
          cur_color = temp_color;
          temp_color = WHITE;
          isDrawing = false;
        }
      }

    if(custom_canvas.drewLastFrame) {
      g.play_script_stream("draw", 2, 0, 0, false, .85);
    } 
    
    if(custom_canvas.erasedLastFrame) {
      audio@ a = g.play_script_stream("erase", 2, 0, 0, false, 1);
      a.time_scale(.65);
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
    g.play_script_stream("splash", 2, 0, 0, false, 10);
  }
}
