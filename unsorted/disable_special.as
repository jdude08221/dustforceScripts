class script : callback_base{
  scene@ g;
  bool comboSaved = false;
  bool superDisabled = false;
  bool saveAndDisable = false;
  bool reapplyAndEnable = false;
  int savedCombo = 0;
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
      if(!comboSaved) {
        // Do not overwrite saved combo if there is one
        saveAndDisable = true;
      }
    } else {
      // Enable special
      if(comboSaved) {
        reapplyAndEnable = true;
      }
    }
  }

  void step(int) {
    controllable@ c = controller_controllable(0);
    if(@c == null) return;
    @player1 = c.as_dustman();
    if(@player1 == null) return;

   if(saveAndDisable) {
    savedCombo = player1.skill_combo();
    g.special_enabled(superDisabled);
    player1.skill_combo(0);
    saveAndDisable = false;
    comboSaved = true;
   }

   if (reapplyAndEnable) {
    player1.skill_combo(savedCombo);
    reapplyAndEnable = false;
    comboSaved = false;
   }

   if(player1.attack_state() == 3) {
    // If a player supers, there should be no combo saved
    savedCombo = 0;
   }
  }
}

class edge_trigger : trigger_base {
  bool activated;
  bool active_this_frame;
  [text] bool is_disable_trigger = true;
  controllable@ trigger_entity;
  
  void init(script@ s, scripttrigger@ self) {

  }
  
  void step() {
  }
  
  void activate(controllable@ e) {
    @trigger_entity = @e;
    message@ msg = create_message();
    msg.set_string('isDisable', is_disable_trigger ? "true" : "false"); 
    broadcast_message('DisableSpecial', msg);
  }
}