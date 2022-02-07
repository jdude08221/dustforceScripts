const string EMBED_music = "climb/snake_eater.ogg";
const string EMBED_bean = "climb/bean.png";

class script
{
  [hidden] float Y1t;
  [position,mode:world,layer:18,y:Y1t] float X1t;
  [text]bool showBoxes;
  [text]float speed;
  [text]float X1;
  [text]float Y1;
  [text]float X2;
  [text]float Y2;
  [entity] int trigger;
  sprites@ spr;
  float fall_accel;
  float hover_accel;
  float jump_a;
  float hop_a;
  float fall_max;
  bool defaultsSet;
  scene@ g;
  audio@ music1;
  
  script()
	{
    defaultsSet = false;
    @g = get_scene();
    X1 = Y1 = X2 = Y2 = 0;
    showBoxes = true;
    @spr = create_sprites();
    @music1 = null;
  }

  void build_sprites(message@ msg) {
    msg.set_string("bean", "bean");
  }

  void step(int) {
    if(@controller_entity(0) == null)
      return;
    dustman@ dm = controller_entity(0).as_dustman();
    float minx = X1 >= X2? X2 : X1;
    float maxx = X1 <= X2? X2 : X1;
    float miny = Y1 >= Y2? Y2 : Y1;
    float maxy = Y1 <= Y2? Y2 : Y1;
    //hardcoded
    if(dm.y() <= -4019 && @music1 == null) {
      float soundx, soundy, volume;
      soundx = soundy = 0;
      volume = .75;
      puts("");
      @music1 = g.play_script_stream('music', 1, soundx, soundy, false, volume);
    }

    if(!defaultsSet) {
        fall_accel = dm.fall_accel();
        hover_accel = dm.hover_accel();
        jump_a = dm.jump_a();
        hop_a = dm.hop_a();
        fall_max = dm.fall_max();

        defaultsSet = true;
    }

    if(dm.x() <= maxx && dm.x() >= minx && dm.y() >= miny && dm.y() <= maxy) {
      dm.set_speed_xy(0,0); 
      dm.fall_accel(0);
      dm.hover_accel(0);
      dm.jump_a(0);
      dm.hop_a(0);
      dm.fall_max(0);
      if(dm.y_intent() == -1) {
          dm.set_xy(dm.x(), dm.y() - speed);
      } else if(dm.y_intent() == 1) {
          dm.set_xy(dm.x(), dm.y() + speed);
      }
    } else {
      dm.fall_accel(fall_accel);
      dm.hover_accel(hover_accel);
      dm.jump_a(jump_a);
      dm.hop_a(hop_a);
      dm.fall_max(fall_max);
    }

    
  }

  void on_level_start() {
    spr.add_sprite_set("script");
  }

  void build_sounds(message@ msg)
  {
    msg.set_string("music", "music");
  }

  void draw(float subframe) {   
    spr.draw_world(12, 1, "bean", 0, 1, X1t, Y1t, 0, 5, 5, 0xFFFFFFFF);
  }

  void editor_draw(float sub_frame) {
    if(showBoxes) {
      g.draw_rectangle_world(18, 10, X1, Y1, X2, Y2, 0, 0x4A00FF00);
    } 
  }

  void editor_step() {
    entity @e = entity_by_id(trigger);
    if(@entity_by_id(trigger) != null && @entity_by_id(trigger).as_scripttrigger() != null) {
      entity_by_id(trigger).as_scripttrigger().editor_colour_circle(0x00000000);
      entity_by_id(trigger).as_scripttrigger().editor_colour_inactive(0x00000000);
      entity_by_id(trigger).as_scripttrigger().editor_colour_active(0x00000000);
    }
  }
}