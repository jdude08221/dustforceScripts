const string EMBED_sound1 = "waterfall1.ogg";// 17 Seconds long
const string EMBED_sound2 = "waterfall1.ogg";// 25 Seconds long
const string EMBED_sound3 = "waterfall1.ogg";// 27 Seconds long
// Put audio files in ...\common\Dustforce\user\embed_src

// Keep adding EMBED_soundN for more audio clips.  Example:
// const string EMBED_sound3 = "thunder4.ogg";

class script {
  scene@ g;
  float t = 0;
  int lastPlayed = 0;
  [text]int delay;
  [option, 1:music, 2:ambience, 3:sfx]int volumeSlider;
  [slider, min:0.0, max:3.0]float volume;
  [text]float x;
  [text]float y;
  [text]int sampleRate;
  
  script() {
    volumeSlider = 1;
    volume = 0.0;
    x = y = 0;
    sampleRate = 44100;
    delay = 120;
    @g = get_scene();
    srand(timestamp_now());
  }

  void build_sounds(message@ msg) {
    msg.set_string("waterfall1", "sound1");

    // call set_string on msg with args like this.  If I had a thunder4.ogg file, I would just add:
    // msg.set_string("thunder4", "sound4");
  }
  
  void step(int entities) {
    
    // So ngl not sure if this actually does proper random choice or whatever, but it seems to work fine enough.
    // You can COMPLETELY not use this logic and only use the g.play_script_stream(...) function to just play a loaded
    // audio clip.
    
    /* The goal of this logic was the following:
     * 1. Wait a random number of frames
     * 2. Randomly select an audio clip which was NOT the last one played
     * 3. Play the audio clip
     * 4. Delay for the duration of the audio clip to avoid playing multiple clips over each other.
     * 5. Repeat
     */

          g.play_script_stream("waterfall1", volumeSlider, x, y, false, volume); // This is what you want


  }
}