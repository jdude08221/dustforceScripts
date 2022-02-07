const string EMBED_sound1 = "al1.ogg"; 
const string EMBED_sound2 = "al2.ogg";
const string EMBED_sound3 = "al3.ogg";
const string EMBED_sound4 = "alm.ogg";

const int MAX_PLAYERS = 4;
// Put audio files in ...\common\Dustforce\user\embed_src
  
class script : callback_base {
  scene@ g;
  audio@ musicHandle; // Unused, and kept apart from ambience
  
  [slider,min:0,max:100] float musicVolume;
  
  array<string> sounds(4);
  array<bool> isFading(4);
  array<int> fadeTime(4);
  array<float> volume(4);
  array<audio@> audioHandles(4);
  bool volumeChanged;
  
  script() { 
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
    volumeChanged = false; 
    @musicHandle = null;
    
    array<int> fadeTime = {0,0,0,0};
    array<float> volume = {0,0,0,0};
    array<audio@> audioHandles = {null, null , null, null};
    
    sounds[0] = EMBED_sound1.split(".")[0];
    sounds[1] = EMBED_sound2.split(".")[0];
    sounds[2] = EMBED_sound3.split(".")[0];
    sounds[3] = EMBED_sound4.split(".")[0];
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('play') == 'true') {   
      int selectedSound = msg.get_int('name')-1;    
      volume[selectedSound] = msg.get_float('volume');
      
      if(audioHandles[selectedSound] == null ) {
          @audioHandles[selectedSound] = 
          g.play_script_stream(sounds[selectedSound], 2, 0, 0, true, volume[0] );
      }        
      // Check if another trigger for an already playing audio stream 
      // wants to adjust the volume.  
      volumeChanged = !closeTo(audioHandles[selectedSound].volume(), volume[selectedSound],0.01);
      
      // If we found a significant volume difference, update fade time 
      // array with most recent fade values for use in step()   
      if(volumeChanged){
        fadeTime[selectedSound] = 60 * msg.get_int('fadeTime');
      }
    }
  }
 
  void on_level_start() {
     @musicHandle = g.play_script_stream(EMBED_sound4.split(".")[0], 2, 0, 0, true, musicVolume/100);
  }
  
  void build_sounds(message@ msg) {
    msg.set_string(EMBED_sound1.split(".")[0], "sound1");
    msg.set_string(EMBED_sound2.split(".")[0], "sound2");
    msg.set_string(EMBED_sound3.split(".")[0], "sound3");
    msg.set_string(EMBED_sound4.split(".")[0], "sound4");
  }
   
  void step(int entities) {
  
    // Volume was changed, start fading audio tracks
    if(volumeChanged) {
      float volChange = 0;
      for(int i = 0; i < 3; i++) {
        if(audioHandles[i] != null) {
          if(fadeTime[i] > 0) {
            float sign = (audioHandles[i].volume() - volume[i]) > 0 ? -1 : 1;
            volChange = audioHandles[i].volume() + (sign/fadeTime[i]);
          } else {
            volChange = volume[i];
          }
          audioHandles[i].volume(volChange);
        }
      }
      
      //Determine if we want to stop fading
      bool stopFading = true;
      for(int i = 0; i < 3; i++) {
        stopFading = stopFading && !(audioHandles[i]!=null && !closeTo(audioHandles[i].volume(), volume[i], 0.01));
      }
      
      // Check to see if we should stop fading audio in / out
      if(stopFading){
        for(int i = 0; i < fadeTime.size(); i++) {
          fadeTime[i]= 0;
        }
        volumeChanged = false;
      }
    }
  }
}

class soundEffect: trigger_base, callback_base {
	script@ script;
	scene@ g;
	scripttrigger @scr;
  [slider,min:0,max:100] float volume;
  [slider,min:0,max:10] float fadeTime; // in seconds
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
    msg.set_float('volume', volume/100);
    msg.set_int('fadeTime', fadeTime);
    msg.set_int('name', sfx);
    broadcast_message('OnMyCustomEventName', msg);
  }
}