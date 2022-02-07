class script  : callback_base {
  [hidden] float textStorageY;
  [position,mode:world,layer:18,y:textStorageY|tooltip:"Where text triggers will stay when not in use.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] float textStorageX;
  [text] array<dialogueHelper> dialogue;
  uint curIndex;
  scene@ g;
  float start;
  bool startScene;
  bool started;
  script() {
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    start = 0;
    @g = get_scene();
    curIndex = 0;
    startScene = false;
    started = false;
  }

  void on_level_start() {
    // set up dialogueHelpers
    for(uint i = 0; i < dialogue.size(); i++) {
      @dialogue[i].e = entity_by_id(dialogue[i].entity_id);
      // Store all triggers except the first in the storage area
      if(i != 0) {
        dialogue[i].e.set_xy(textStorageX, textStorageY);
      }
    }
  }

    void OnMyCustomEventName(string id, message@ msg) {
        if(msg.get_string('startScene') == 'true') {  
            if(!startScene) {
              startScene = true;
              start = get_time_us();
              puts("start");
            }
        }
    }

  void step(int entities) {
    if(startScene &&
      curIndex < dialogue.size() &&
      !dialogue[curIndex].displayForever &&
      get_time_us() - start >= dialogue[curIndex].displayTime * 1000000) {
        
        start = get_time_us();
        if(curIndex + 1 < dialogue.size()) {
          // Move next text in
          dialogue[curIndex + 1].e.set_xy(dialogue[curIndex].e.x(), dialogue[curIndex].e.y());
        }
        // Move current text to storage area
        dialogue[curIndex].e.set_xy(textStorageX, textStorageY);
        curIndex++;
    }
  }
}

class dialogueHelper {
  [entity] int entity_id;
  [text|tooltip:"In seconds.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] float displayTime;
  [text] bool displayForever;
  entity@ e;

  dialogueHelper() {
    displayTime = 0;
    entity_id = 0;
  }
}

class startText : trigger_base, callback_base { 
      
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
        msg.set_string('startScene', "true");
        broadcast_message('OnMyCustomEventName', msg);  
    }

    void falling_edge(controllable@ e) {
        @trigger_entity = null;
        //do stuff
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
