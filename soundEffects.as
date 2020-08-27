const string EMBED_sound1 = "sound1.ogg"; 
const string EMBED_sound2 = "sound2.ogg";
const string EMBED_sound3 = "sound3.ogg";
const string EMBED_sound4 = "music.ogg"; // this should be the music track if you want it.  If you dont want music, go to on_level_start() and delete 
                                         // @musicHandle = g.play_script_stream(EMBED_sound4.split(".")[0], 2, 0, 0, true, musicVolume/100);
const string EMBED_sound5 = "sound4.ogg";
const string EMBED_sound6 = "sound5.ogg";
const string EMBED_sound7 = "sound6.ogg";
const string EMBED_sound8 = "sound7.ogg";
const string EMBED_sound9 = "sound8.ogg";
const string EMBED_sound10 = "sound9.ogg";
const uint WHITE = 4294967295;

const int NUM_SOUNDS = 10; // Update this to be the number of EMBED sounds
const int MAX_PLAYERS = 4;
// Put audio files in ...\common\Dustforce\user\embed_src
  
class script : callback_base {
  scene@ g;
  audio@ musicHandle; // At the moment, this is unused.
  
  [slider,min:0,max:100] float musicVolume;
  
  array<string> sounds(NUM_SOUNDS);
  array<bool> isFading(NUM_SOUNDS);
  array<float> fadeTime(NUM_SOUNDS);
  array<float> volume(NUM_SOUNDS);
  array<audio@> audioHandles(NUM_SOUNDS);
  bool volumeChanged;
  
  script() { 
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    @g = get_scene();
    volumeChanged = false; 
    @musicHandle = null;

    array<int> fadeTime = {0,0,0,0};
    array<float> volume = {0,0,0,0};

    array<audio@> audioHandles = {null, null, null, null, null,
                                  null, null, null, null, null};

    sounds[0] = EMBED_sound1.split(".")[0];
    sounds[1] = EMBED_sound2.split(".")[0];
    sounds[2] = EMBED_sound3.split(".")[0];
    sounds[3] = EMBED_sound4.split(".")[0];
    sounds[4] = EMBED_sound5.split(".")[0];
    sounds[5] = EMBED_sound6.split(".")[0];
    sounds[6] = EMBED_sound7.split(".")[0];
    sounds[7] = EMBED_sound8.split(".")[0];
    sounds[8] = EMBED_sound9.split(".")[0];
    sounds[9] = EMBED_sound10.split(".")[0];
  }
  
  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('play') == 'true') {   
      int selectedSound = msg.get_int('name')-1;    
      volume[selectedSound] = msg.get_float('volume');
      uint soundGroup = msg.get_int('soundGroup');
      bool loop = msg.get_int('loop') == 1;
      
      // if no existing audio stream is playing the requested sound, play it
      if(@audioHandles[selectedSound] == null || !audioHandles[selectedSound].is_playing()) {
          @audioHandles[selectedSound] = 
          g.play_script_stream(sounds[selectedSound], soundGroup, 0, 0, loop, volume[0] );
      }

      // Check if the last trigger which requested current audio clip has a notable difference in volume  
      volumeChanged = !closeTo(audioHandles[selectedSound].volume(), volume[selectedSound],0.01);
      
      // If a notable difference of volume is found, we want to  
      if(volumeChanged){
        fadeTime[selectedSound] = 60 * msg.get_float('fadeTime');
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
    msg.set_string(EMBED_sound5.split(".")[0], "sound5");
    msg.set_string(EMBED_sound6.split(".")[0], "sound6");
    msg.set_string(EMBED_sound7.split(".")[0], "sound7");
    msg.set_string(EMBED_sound8.split(".")[0], "sound8");
    msg.set_string(EMBED_sound9.split(".")[0], "sound9");
    msg.set_string(EMBED_sound10.split(".")[0], "sound10");
  }
   
  void step(int entities) {
  
    // if volume was changed, start fading audio tracks
    if(volumeChanged) {
      float volChange = 0;

      // go through all sounds and apply fades.  If a sound isn't supposed to fade, fadeTime[i] will be 0, and nothing will be applied to it.
      for(int i = 0; i < NUM_SOUNDS - 1; i++) {
        if(@audioHandles[i] != null) {
          if(fadeTime[i] > 0) {
            //Determine if we want to fade in or fade out audio.
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
      for(int i = 0; i < NUM_SOUNDS - 1; i++) {
        stopFading = stopFading && !(@audioHandles[i]!=null && !closeTo(audioHandles[i].volume(), volume[i], 0.01));
      }
      
      // Check to see if we should stop fading audio in / out
      if(stopFading){
        for(uint i = 0; i < fadeTime.size(); i++) {
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
  bool activated;
  bool active_this_frame;
  controllable@ trigger_entity;

  [slider,min:0,max:100] float volume;
  [slider,min:0,max:10] float fadeTime; // in seconds
  [text]bool loop;
  [text]bool playOncePerActivation;
  [text]bool showRadius;
  
  [option,1:sound1,2:sound2,3:sound3,4:sound4,5:sound5,6:sound6,7:sound7,8:sound8,9:sound9,10:sound10]int sfx;
  [option,1:music,2:ambience,3:sfx] uint soundGroup;
    
  soundEffect() {
    sfx = 1;
    @g = get_scene();  
    volume = 0;
    fadeTime = 0;
    loop = false;
    playOncePerActivation = false;
    showRadius = true;
    sfx = 1;
    soundGroup = 2;
  }
  
  void init(script@ s, scripttrigger@ self) {  
    @scr = self;
    scr.editor_show_radius(false);
    scr.editor_colour_circle(WHITE);
    scr.editor_colour_inactive(WHITE);
    scr.editor_colour_active(WHITE);
    activated = false;
    active_this_frame = false;
  }
    
  void editor_step() {
      scr.editor_show_radius(showRadius);
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

  void activate(controllable @e) {   

    if(e.player_index() == 0) {
        if(not activated) {
            rising_edge(@e);
            activated = true;
        }
        active_this_frame = true;
    }

    if (@e.as_dustman() == null) {
        return;
    }
    // If we do want to constantly replay the sound while in the trigger
    if(!playOncePerActivation) {
      message@ msg;
      @msg = create_message(); 
      msg.set_string('play', 'true');
      msg.set_float('volume', volume/100);
      msg.set_float('fadeTime', fadeTime);
      msg.set_int('name', sfx);
      msg.set_int('loop', loop?1:0);
      msg.set_int('soundGroup',soundGroup);
      broadcast_message('OnMyCustomEventName', msg);
    }
  }

  void rising_edge(controllable@ e) {
    @trigger_entity = @e;
    // If we don't want to constantly replay the sound while in the trigger
    if(playOncePerActivation) {
      message@ msg;
      @msg = create_message(); 
      msg.set_string('play', 'true');
      msg.set_float('volume', volume/100);
      msg.set_float('fadeTime', fadeTime);
      msg.set_int('name', sfx);
      msg.set_int('loop', loop?1:0);
      msg.set_int('soundGroup',soundGroup);
      broadcast_message('OnMyCustomEventName', msg);
    }
  }

  void falling_edge(controllable@ e) {
      @trigger_entity = null;
  }
}