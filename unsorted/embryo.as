class script : callback_base{
  scene@ g;
  entity@ totem;
  bool firstTime = true;
  
  script() {
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
  }
  void OnMyCustomEventName(string id, message@ msg) {
    if(!firstTime) {
      puts("hi");
      clear_canvas();
    }
    puts("hi");
     firstTime = false;
  }

  void clear_canvas() {
    //Clear canvas
    dustman@ dm = controller_entity(0).as_dustman();

    //Spawn large totem above dustman in attacking state and add to scene
          for(uint i = 0; i < 10; i++) {
        @totem = create_entity("enemy_stoneboss");
        totem.as_controllable().scale(5, false);
        totem.set_xy(dm.x()+(i*(2*48)), dm.y()-100);
        totem.as_controllable().attack_state(1);
        g.add_entity(totem);
      }

      
  }

  void step(int) {
    
  }

}

class edge_trigger : trigger_base, callback_base {
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
        msg.set_string('trigger', "true");
        broadcast_message('OnMyCustomEventName', msg);  
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
            if(not activated) {
                rising_edge(@e);
                activated = true;
            }
            active_this_frame = true;
        }
    }
}
