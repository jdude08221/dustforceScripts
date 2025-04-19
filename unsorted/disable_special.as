class script : callback_base{
  scene@ g;
  bool comboSaved = false;
  bool superDisabled = false;
  int comboCount = 0;
  dustman@ player1;
  
  script() {
    add_broadcast_receiver('DisableSpecial', this, 'DisableSpecial');
    @g = get_scene();
  }

  void DisableSpecial(string id, message@ msg) {
    if(@player1 == null) return;

    if(msg.get_string('isDisable') == "true") {
      // Disable special
      superDisabled = true;

      // Save the combo if its not already
      if(comboSaved) return;
      comboCount = player1.skill_combo();
      comboSaved = true;
      
    } else {
      // Enable special
      comboSaved = false;
      superDisabled = false;
    }
  }

  void step(int) {
    controllable@ c = controller_controllable(0);
    if(@c == null) return;
    @player1 = c.as_dustman();
    if(@player1 == null) return;

    g.special_enabled(superDisabled);
    player1.skill_combo(superDisabled ? 0 : comboCount);
  }

}

class edge_trigger : trigger_base, callback_base {
    bool activated;
    bool active_this_frame;
    [text] bool is_disable_trigger = true;
    controllable@ trigger_entity;
    
    void init(script@ s, scripttrigger@ self) {
        activated = false;
        active_this_frame = false;
    }
    
    void rising_edge(controllable@ e) {
        @trigger_entity = @e;
        message@ msg = create_message();
        msg.set_string('isDisable', is_disable_trigger ? "true" : "false"); 
        broadcast_message('DisableSpecial', msg); 
    }

    void falling_edge(controllable@ e) {
        @trigger_entity = null;
        // do stuff
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
            if(!activated) {
                rising_edge(@e);
                activated = true;
            }
            active_this_frame = true;
        }
    }
}
