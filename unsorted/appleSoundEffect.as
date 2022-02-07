const string EMBED_sound1 = "apple.ogg";

const int MAX_PLAYERS = 4;
// Put audio files in ...\common\Dustforce\user\embed_src

class script : callback_base{
  scene@ g;
  audio@ applehandle;
  bool playSound;
  
  script() {
    playSound = true;
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('play') == 'true') {  
      if(playSound) {
        puts("play");
        playSound = false;  
        @applehandle = g.play_script_stream("apple", 2, 0,0, false, 0  );
        applehandle.volume(1.0);
      } 
    } else if(msg.get_string('reset') == 'true') {
      puts("reset");
      playSound = true;
    }
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("apple", "sound1");
  }
  
  void on_level_start() {
  }
  
  void step(int entities) {
  }
}

class soundEffect: trigger_base, callback_base {
  
	script@ script;
	scene@ g;
	scripttrigger @scr;
  [text]bool showRadius;
  [text]bool reset;
  
  soundEffect() {
    @g = get_scene();  
    showRadius = false;
    reset = false;
  }
  
  void init(script@ s, scripttrigger@ self) {  
    @scr = self;
    scr.editor_show_radius(false);
  }
  
  void editor_step() {
      scr.editor_show_radius(showRadius);
  }
  
  void activate(controllable @e) {   
  if (e.as_dustman() == null) {
        return;
  } 
  
  if(reset) {
    message@ msg = create_message();
      msg.set_string('reset', "true");
      broadcast_message('OnMyCustomEventName', msg);   
  } else {
      message@ msg = create_message();
      msg.set_string('play', "true");
      broadcast_message('OnMyCustomEventName', msg);    
  }
  }
}