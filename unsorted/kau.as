class script : callback_base{
  bool disableHeavy = false;
  script() {
    add_broadcast_receiver('noHeavy', this, 'noHeavy');
  }

  void noHeavy(string id, message@ msg) {
    if(msg.get_string('enable') == 'true') {  
      disableHeavy = true;
    } else if(msg.get_string('enable') == 'false') {
      disableHeavy = false;
    }
  }

  void on_level_start() {

  }

  void step(int) {
    dustman@ dm = null;
    for(uint i = 0; i < 4; i++) {
       if(@controller_entity(i) != null && @controller_entity(i).as_dustman() != null) {
         @dm = controller_entity(i).as_dustman();

         if(disableHeavy) {
           if(!(dm.light_intent() > 0 && dm.combo_count() >= 100)) {
             dm.heavy_intent(0);
           }
         }
       }
    }
  }
}


class noHeavyTrigger : trigger_base  {
  bool activated;
    bool active_this_frame;
    controllable@ trigger_entity;
    
    void init(script@ s, scripttrigger@ self) {
        activated = false;
        active_this_frame = false;
    }
    
    void rising_edge(controllable@ e) {
      @trigger_entity = @e;
      message@ msg = create_message();
      msg.set_string('enable', "true");
      broadcast_message('noHeavy', msg); 
    }

    void falling_edge(controllable@ e) {
      @trigger_entity = null;
      message@ msg = create_message();
      msg.set_string('enable', "false");
      broadcast_message('noHeavy', msg); 
    }
    
    void step() {
        if(activated) {
            if(not active_this_frame) {
                activated = false;
                falling_edge(@trigger_entity);
            }
            active_this_frame = false;
        }
    }
    
    void activate(controllable@ e) {
        if(e.player_index() == 0) {
            if(not activated) {
                rising_edge(@e);
                activated = true;
            }
            active_this_frame = true;
        }
    }
}