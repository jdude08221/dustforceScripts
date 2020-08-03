const string EMBED_sound1 = "amb1.ogg";
const string EMBED_sound2 = "amb2.ogg";
const string EMBED_sound3 = "amb3ice.ogg";
const string EMBED_sound4 = "Gscy.ogg";

const int MAX_PLAYERS = 4;
// Put audio files in ...\common\Dustforce\user\embed_src

class script : callback_base {
  scene@ g;
  
  audio@ amb1Handle;
  audio@ amb2Handle;
  audio@ amb3iceHandle;
  audio@ GscyHandle;
  
  [slider,min:0,max:1] float Gscy_volume;
  
  array<string> sounds(4);
  array<bool> isFading(4);
  array<int> fadeTime(4);
  array<float> volume(4);
  array<audio@> audioHandles(4);
  bool volumeChanged;
  
  script() {
    volumeChanged = false;
    
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
    
    @amb1Handle = null;
    @amb2Handle = null;
    @amb3iceHandle = null;
    @GscyHandle = null;
    
    array<int> fadeTime = {0,0,0,0};
    array<float> volume = {0,0,0,0};
    array<audio@> audioHandles = {null, null , null, null};
    sounds[0] = 'amb1';
    sounds[1] = 'amb2';
    sounds[2] = 'amb3ice';
    sounds[3] = 'Gscy';
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('play') == 'true') {   
      int selectedSound = msg.get_int('name')-1;
      
      volume[selectedSound] = msg.get_float('volume');
      if(selectedSound == 0) {       
        if(@amb1Handle == null ) {
          @amb1Handle = g.play_script_stream(
                      sounds[selectedSound], 2, 0, 0, true, volume[0] );
        } 
        volumeChanged = !closeTo(amb1Handle.volume(), volume[0],0.01);
        if(volumeChanged){
          fadeTime[0] = 60* msg.get_int('fadeTime');
        }
      } else if(selectedSound == 1) {
          if(@amb2Handle == null) {
            @amb2Handle = g.play_script_stream(
                          sounds[selectedSound], 2, 0, 0, true, volume[1] );
          }    
          volumeChanged = !closeTo(amb2Handle.volume(), volume[1],0.01);
          if(volumeChanged){
            fadeTime[1] = 60 * msg.get_int('fadeTime');
          }
      } else if(selectedSound == 2) {
        if(@amb3iceHandle == null) {
          @amb3iceHandle = g.play_script_stream(
                           sounds[selectedSound], 2, 0, 0, true, volume[2] );
        } 
        volumeChanged = !closeTo(amb3iceHandle.volume(), volume[2],0.01);
        if(volumeChanged){
          fadeTime[2] = 60 * msg.get_int('fadeTime');
        }
      } else {
        //Shouldn't happen
        }
    }

  }
  
  /** 'soundGroup' determines which global volume slider to apply to this sound.
   * 1 for music, 2 for ambience, and anything else is considered a sound
   * effect. */
  void on_level_start() {
     //@GscyHandle = g.play_script_stream("Gscy", 2, 0, 0, true, Gscy_volume);
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("amb1", "sound1");
    msg.set_string("amb2", "sound2");
    msg.set_string("amb3ice", "sound3");
    msg.set_string("Gscy", "sound4");
  }
  
  
  void step(int entities) {
    if(volumeChanged) {
      //puts("volume changed");
      float volChange = 0;
      
      if(amb1Handle!=null && !closeTo(amb1Handle.volume(), volume[0], 0.01)) { 
        if(fadeTime[0] > 0) {
          volChange = amb1Handle.volume() - ((amb1Handle.volume() - volume[0])/fadeTime[0]);
        } else {
          volChange = volume[0];
        }
        //puts("changing outside volume to: " + volChange);
        amb1Handle.volume(volChange);
      } if(amb2Handle!=null && !closeTo(amb2Handle.volume(), volume[1], 0.01)) {
          if(fadeTime[1] > 0){
            volChange = amb2Handle.volume() - ((amb2Handle.volume() - volume[1])/fadeTime[1]);
          } else {
            volChange = volume[0];
          }
          //puts("changing cave volume to: " + volChange);
          amb2Handle.volume(volChange);
      } if(amb3iceHandle!=null && !closeTo(amb3iceHandle.volume(), volume[2], 0.01)) {
          if(fadeTime[2] > 0) {
            volChange = amb3iceHandle.volume() - ((amb3iceHandle.volume() - volume[2])/fadeTime[2]);
          } else {
            volChange = volume[0];
          }
          //puts("changing volume to: " + volChange);
          amb3iceHandle.volume(volChange);
      } if(!(amb1Handle!=null && !closeTo(amb1Handle.volume(), volume[0], 0.01))&&
           !(amb2Handle!=null && !closeTo(amb2Handle.volume(), volume[1], 0.01)) && 
           !(amb3iceHandle!=null && !closeTo(amb3iceHandle.volume(), volume[2], 0.01))){
          puts("volume change done ");
          fadeTime[0] = 0;
          fadeTime[1] = 0;
          fadeTime[2] = 0;    
          volumeChanged = false;
      }
    }
  }
}

class soundEffect: trigger_base, callback_base {
  
	script@ script;
	scene@ g;
	scripttrigger @scr;
  
  [slider,min:0,max:1] float volume;
  [slider,min:0,max:5] float fadeTime;
  [text]bool showRadius;
  [option,1:windOutside,2:windCave,3:ice]int sfx;
  
  soundEffect() {
    sfx = 1;
    @g = get_scene();  
    showRadius = false;
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
  
    message@ msg;
    @msg = create_message(); 
    msg.set_string('play', 'true');
    msg.set_float('volume', volume);
    msg.set_int('fadeTime', fadeTime);
    msg.set_int('name', sfx);
    broadcast_message('OnMyCustomEventName', msg);
  }
}