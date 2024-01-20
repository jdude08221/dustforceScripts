#include "../../lib/math/Rect.cpp"
#include "../../lib/ui/Button.cpp"
#include "../../lib/ui/label.cpp"
#include "../../lib/ui/UI.cpp"

#include "../../lib/math/math.cpp"

#include "../jlib/const/ColorConsts.as"
#include "../jlib/ui/CustomCanvas.as"
#include "../jlib/ui/ColorSwab.as"
#include "../jlib/ui/LabelButton.as"

const int NUM_FRAMES_CLICK = 4; 
const string EMBED_yellowclick0 = "osrs/click/299_0.png";
const string EMBED_yellowclick1 = "osrs/click/299_1.png";
const string EMBED_yellowclick2 = "osrs/click/299_2.png";
const string EMBED_yellowclick3 = "osrs/click/299_3.png";

const string EMBED_rightClickBox = "osrs/right_click/right_click_box.png";


class script : callback_base{
  scene@ g;
  UI@ ui = UI();
  Mouse@ mouse = ui.mouse;
  bool right_mouse_down;
  [position,mode:world,layer:18,y:pbY1] float pbX1;
  [hidden] float pbY1;
  [hidden]LabelButton @play_button;
  [hidden] bool leftMousePressed;
  [hidden] bool leftMouseDown;
  [hidden] bool middle_mouse_down;
  Rect rightClickRect;
  
  uint frame;
  uint curYellowClickFrame;

  RightClickContainer@ cont;

  //Arrays of animation frames and sprite vars
  uint yellow_click_total_frames = 1;
  bool animating_yellow_click = false;
  float draw_yellow_click_x = 0;
  float draw_yellow_click_y = 0;
  sprites@ spr;
  array<string>framesYellowClick(NUM_FRAMES_CLICK);

  //movement vars
  bool moving;
  float target_x;
  float target_y;
  bool dismissRightClick;
  bool doJump = false;
  int jumpFrames;

  script() {
    @g = get_scene();
    init_buttons();

    @spr = create_sprites();
    right_mouse_down = false;
    leftMousePressed = false;
    middle_mouse_down = false;
    curYellowClickFrame = 0;

    add_broadcast_receiver('jump', this, 'jump');
    add_broadcast_receiver('cancel', this, 'cancel');
  }

  void on_level_start() {
    init_buttons();
    init_sprite_arrays();
    spr.add_sprite_set("script");
  }

  void init_sprite_arrays() {
    for(int i = 1; i <= NUM_FRAMES_CLICK; i++) {
      framesYellowClick[i-1] = "yellowclick" + i;
    }
  }

  void jump(string id, message@ msg) {
    //TODO: implement jump
    puts("JUMP");
    cont.dismiss();
    doJump = true;
  }

  void cancel(string id, message@ msg) {
    puts("CANCEL");
    cont.dismiss();
  }

  void init_buttons() {
    @play_button = LabelButton(ui, pbX1, pbY1, "play_animation", "Play!");
  }

  void build_sounds(message@ msg) {
 
  }

  void build_sprites(message@ msg) {
    for(int i = 1; i <= NUM_FRAMES_CLICK; i++) {
      msg.set_string("yellowclick"+i,"yellowclick"+i); 
    }

    msg.set_string("rightClickBox", "rightClickBox");
  }

  void step(int) {
    dustman@ dm;
    
    if(@controller_entity(0) != null) {
      @dm = controller_entity(0).as_dustman();
    } else {
      return;
    }
    if(@dm == null) {
      return;
    }

    dm.x_intent(0);
    dm.y_intent(0);
    dm.jump_intent(0);
    dm.dash_intent(0);
    if(doJump) {
      dm.jump_intent(1);
      if(jumpFrames < 8) {
        jumpFrames++;
      } else {
        jumpFrames = 0;
        doJump = false;
      }
    }
    
    step_ui();

    float mouse_x = g.mouse_x_world(0, 18);
    float mouse_y = g.mouse_y_world(0, 18);
    
    ui.step();
    
    //handle mouse inputs
    right_mouse_down = get_right_mouse_down(0);
    leftMousePressed = get_left_mouse_down(0);
    middle_mouse_down = get_mouse_middle_down(0);

    if(get_mouse_scroll_down(0)) {
      
    } else if(get_mouse_scroll_up(0)) {
      
    }

    if(leftMousePressed) {
      //Handle Left mouse pressed
      handleLeftClick(dm);
      leftMouseDown = true;
    } else {
      leftMouseDown = false;
    }


    if(right_mouse_down) {
      createContextMenu();
    }
    
    if (middle_mouse_down) {
      //Handle middle mouse down
    }
    

    //Handle movement
    if(moving) {
      moveCharacter(dm);
    }

    if(@cont != null) {
    float mouse_x_hud = g.mouse_x_hud(0);
    float mouse_y_hud = g.mouse_y_hud(0);
      if(mouse_x_hud < rightClickRect.x1 ||
         mouse_x_hud > rightClickRect.x2 ||
         mouse_y_hud < rightClickRect.y1 ||
         mouse_y_hud > rightClickRect.y2) {
           cont.dismiss();
         }
    }

    frame++;
  }
  void step_post(int entities) {
    
  }
  void createContextMenu() {
    float mouse_x = g.mouse_x_hud(0);
    float mouse_y = g.mouse_y_hud(0);

    //TODO: determine mouse context here... if needed
     
    /*g.draw_rectangle_hud(22,22,mouse_x-100, mouse_y-10, 
    mouse_x+113, mouse_y+107, 0, 0xFFFFFFFF);*/
    rightClickRect = Rect(mouse_x-115, mouse_y-10, mouse_x+113, mouse_y+107);
    if(@cont == null || cont.dismissed()) {
      array<LabelButton@> buttons(2);
      @buttons[0] = LabelButton(ui, mouse_x+107, mouse_y+35, "jump",   "Jump                  ");
      @buttons[1] = LabelButton(ui, mouse_x+103, mouse_y+59, "cancel", "Cancel               ");
      @cont = RightClickContainer(mouse_x, mouse_y, buttons, spr);
    }
  }

  void handleLeftClick(dustman@ dm) {
    float mouse_x = g.mouse_x_world(0, 18);
    float mouse_y = g.mouse_y_world(0, 18);
    if(!leftMouseDown && inWalkableBoundary(g.mouse_x_hud(0), g.mouse_y_hud(0))) {
      curYellowClickFrame = 0;
      animating_yellow_click = true;
      target_x = mouse_x-15;
      target_y = mouse_y-15;
      moving = true;
    }
    dismissRightClick = true;
  }

  void moveCharacter(dustman@ dm) {
    //Check proximity to target
    if(abs(dm.x() - target_x) > 10) {
      dm.x_intent(dm.x() > target_x ? -1 : 1);
    } else {
      moving = false;
    }

    if(dm.y() - target_y > 47) {
      dm.y_intent(-1);
    } else if (dm.y() - target_y < 47) {
      dm.y_intent(1);
    } else {
      dm.y_intent(0);
    }
  }

  bool inWalkableBoundary(float mouse_x, float mouse_y) {
    //TODO: Implement function to determine if mouse click should move the character, aka, in the screen
    return @cont == null || 
    cont.dismissed() ||
    (mouse_x < rightClickRect.x1 ||
    mouse_x > rightClickRect.x2 ||
    mouse_y < rightClickRect.y1 ||
    mouse_y > rightClickRect.y2);
  }

  void draw_ui() {
    //play_button.draw();
    if(@cont != null) {
      cont.draw();
    }
  }

  void step_ui() {
    //play_button.step();
    if(@cont != null) {
      cont.step();
    }
  }

  void draw(float sub_frame) {
    draw_ui();
    draw_hud();
    draw_clicks();
    draw_right_click();
  }

  void draw_right_click() {
    if(@cont != null) {
      cont.draw();
    }
  }

  void draw_clicks() {
    if(animating_yellow_click) {
      spr.draw_world(20, 20, framesYellowClick[curYellowClickFrame], 0, 1, 
      target_x, target_y, 0, 1, 1, 0xFFFFFFFF);
          //update yellow click frames
      if(yellow_click_total_frames%24 == 0) {
        if(curYellowClickFrame < framesYellowClick.size() - 1) {
          curYellowClickFrame++;
        } else {
          curYellowClickFrame = 0;
          animating_yellow_click = false;
        }
      }
      yellow_click_total_frames++;
    } else {
      yellow_click_total_frames = 1;
    }
  }


  void draw_hud() {

  }

  void editor_draw(float sub_frame) {
    //draw canvas and buttons
    draw_ui();
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

class RightClickContainer {
  int NumOptions;
  float x, y;
  array<LabelButton@> options;
  sprites@ spr;
  bool dis = false;

  RightClickContainer(float x, float y, array<LabelButton@> opts, sprites@ spr) {
    this.x = x-90;
    this.y = y;
    options = opts;
    @this.spr = spr;
  }

  void draw() {
    if(dis)
      return;
    for(uint i = 0; i < options.size(); i++) {
      options[i].draw(false, false);
    }
    spr.draw_hud(12, 17, "rightClickBox", 0, 1, 
      x, y, 0, 1, 1, 0xFFFFFFFF);
  }



  void step() {
    if(dis)
      return;
    for(uint i = 0; i < options.size(); i++) {
      options[i].step();
    }
  }

  void dismiss() {
    dis = true;
  }

  bool dismissed() {
    return dis;
  }
}
