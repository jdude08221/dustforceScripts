const int MAX_PLAYERS = 4;

class script : callback_base {
  array<bool> intents(0);
  array<int> intentVals(0);
  scene@ g;
  script() {
    @g = get_scene();
    add_broadcast_receiver('controlTriggerMessage', this, 'controlTriggerMessage');
  }

  void controlTriggerMessage(string id, message@ msg) {
    if(msg.get_string('triggerType') == 'control_trigger') {
      intents.removeRange(0, intents.size());
      intentVals.removeRange(0, intents.size());

      intents.insertLast(stb(msg.get_string('move_x')));
      intentVals.insertLast(msg.get_int('move_x_val'));

      intents.insertLast(stb(msg.get_string('move_y')));
      intentVals.insertLast(msg.get_int('move_y_val'));

      intents.insertLast(stb(msg.get_string('taunt')));
      intentVals.insertLast(msg.get_int('taunt_val'));

      intents.insertLast(stb(msg.get_string('heavy')));
      intentVals.insertLast(msg.get_int('heavy_val'));

      intents.insertLast(stb(msg.get_string('light')));
      intentVals.insertLast(msg.get_int('light_val'));

      intents.insertLast(stb(msg.get_string('dash')));
      intentVals.insertLast(msg.get_int('dash_val'));

      intents.insertLast(stb(msg.get_string('jump')));
      intentVals.insertLast(msg.get_int('jump_val'));

      intents.insertLast(stb(msg.get_string('downdash')));
      intentVals.insertLast(msg.get_int('downdash_val'));
      
    }
  }

  private bool stb(string s) {
    return s == 'true';
  }

  void applyIntents(dustman@ dm, int) {
    for(uint i = 0; i < intents.size(); i++) {
      if(intents[i]) {
        applyIntent(dm, i, intentVals[i]);
      }
    }
  }

    void resetIntents(dustman@ dm, int) {
      //do nothing
    }
    
    void applyIntent(dustman@ dm, int intent, int val) {
      if(@dm == null)
        return;
      switch(intent) {
        case x_intent:
          dm.x_intent(val);
          break;
        case y_intent:
          dm.y_intent(val);
          break;
        case taunt_intent:
          dm.taunt_intent(val);
          break;
        case heavy_intent:
          dm.heavy_intent(val);
          break;
        case light_intent:
          dm.light_intent(val);
          break;
        case dash_intent:
          dm.dash_intent(val);
          break;
        case jump_intent:
          dm.jump_intent(val);
          break;  
        case fall_intent:
          dm.fall_intent(val);
          break;
      }
    }
}

enum intents {
  x_intent=0,
  y_intent=1,
  taunt_intent=2,
  heavy_intent=3,
  light_intent=4,
  dash_intent=5,
  jump_intent=6,
  fall_intent=7,
};

class controlTrigger : trigger_base, callback_base {
    bool activated;
    bool active_this_frame;
    bool levelStart = true;
    controllable@ trigger_entity;
    script@ scr;
    [text|tooltip:"When checked, this option will repeat the intent while in this\ntrigger.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] bool repeat;
    [text] bool move_x;
    [text] int move_x_val;
    [text] bool move_y;
    [text] int move_y_val;
    [text] bool taunt;
    [text] int taunt_val;
    [text] bool heavy;
    [text] int heavy_val;
    [text] bool light;
    [text] int light_val;
    [text] bool dash;
    [text] int dash_val;
    [text] bool jump;
    [text] int jump_val;
    [text] bool downdash;
    [text] int downdash_val;

    void init(script@ s, scripttrigger@ self) {
        activated = false;
        active_this_frame = false;
        @scr = s;
    }
    
    void rising_edge(controllable@ e) {
      @trigger_entity = @e;
    }


    void falling_edge(controllable@ e) {
      @trigger_entity = null;
      message@ msg = create_message();
      if(repeat &&
         @e != null && 
         @e.as_dustman() != null) {
        dustman@ dm = e.as_dustman();
        
        dm.on_subframe_end_callback(scr, "resetIntents", 0);
      }
    }
    
    void setup() {
      if(repeat) {
        message@ msg = create_message();
        msg.set_string('triggerType', 'control_trigger');
        msg.set_string('move_x', bts(move_x));
        msg.set_string('move_y', bts(move_y));
        msg.set_string('taunt', bts(taunt));
        msg.set_string('heavy', bts(heavy));
        msg.set_string('light', bts(light));
        msg.set_string('dash', bts(dash));
        msg.set_string('jump', bts(jump));
        msg.set_string('downdash', bts(downdash));

        msg.set_int('move_x_val', move_x_val);
        msg.set_int('move_y_val', move_y_val);
        msg.set_int('taunt_val', taunt_val);
        msg.set_int('heavy_val', heavy_val);
        msg.set_int('light_val', light_val);
        msg.set_int('dash_val', dash_val);
        msg.set_int('jump_val', jump_val);
        msg.set_int('downdash_val', downdash_val);
        broadcast_message('controlTriggerMessage', msg);
      }

    }

    private string bts(bool b) {
      return b ? 'true' : 'false';
    }
    
    void step() {
      if(levelStart) {
        setup();
        levelStart = false;
      }

      if(activated) {
          if(not active_this_frame) {
              activated = false;
              falling_edge(@trigger_entity);
          }
          active_this_frame = false;
      }
    }
    
    void activate(controllable@ e) {
      if(e.player_index() < MAX_PLAYERS) {
          if(not activated) {
              rising_edge(@e);
              activated = true;
          }
          active_this_frame = true;
      }

      if(repeat) {
        if(@e != null && 
        @e.as_controllable() != null && 
        @e.as_controllable().as_dustman() != null) {
          dustman@ dm = e.as_controllable().as_dustman();
          dm.on_subframe_end_callback(scr, "applyIntents", 0);
        }
      }
    }

    
}

