const int NUM_FRAMES = 1;
const string EMBED_out1 = "frames/out1.png"; 

const string EMBED_sound1 = "song.ogg"; 

class script : callback_base{
  int frame_count;
  int draw_frame_count;
  int last_phys_frame;
  int stupid;
  audio@ badSong;
  sprites@ spr;
  scene@ g;
  bool playing;
  float X1;
  [hidden] float Y1;
  [hidden] int playbackFrames;
array<string>framesGlobal(NUM_FRAMES);
  script() {
      @g = get_scene();
      X1 = 0;
      Y1 = 0;
      frame_count = 0;
      playbackFrames = 0;
      draw_frame_count = 0;
      last_phys_frame = 0;
      playing = false;
      stupid = 0;
      @spr = create_sprites();
      array<string>frames = {
        "out1"
      };

    framesGlobal = frames;
  }

  void build_sprites(message@ msg) {
      msg.set_string("out1","out1"); 
  }

   void build_sounds(message@ msg) {
    msg.set_string(EMBED_sound1.split(".")[0], "sound1");
  }

  void on_level_start() {
    playing = false;
    spr.add_sprite_set("script");  
  }

  void step(int) {
    entity@ dm = controller_entity(0);
    X1 = dm.x();
    Y1 = dm.y();
    frame_count++;
  }

  void draw(float subframe) {
    
    if(draw_frame_count % 52 == 0) {
      if(!playing) {
        @badSong = g.play_script_stream(EMBED_sound1.split(".")[0], 3, 0, 0, true, 1 );
        playing = true;
      }
      stupid++;
    }
    spr.draw_world(20, 1, framesGlobal[stupid % NUM_FRAMES], 0, 1, X1-140, Y1-350,
                    0, 8, 8, 0xFFFFFFFF);
    
    draw_frame_count++;
  }
}