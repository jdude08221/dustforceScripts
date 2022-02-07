const string EMBED_music1 = "twirlieTime/Cider_Time_163.ogg";
const string EMBED_music2 = "twirlieTime/Cider_Time_180.ogg";

class script
{
  
  scene@ g;
  audio@ music;
  audio@ music2;
  bool isPlaying;
  
  
  script()
	{
    @music = null;
    @g = get_scene();
  }
  
  void build_sounds(message@ msg)
  {
    msg.set_string("music1", "music1");
    msg.set_string("music2", "music2");
    msg.set_int("music1|loop", 519806);
    msg.set_int("music2|loop", 469939);
  }
  
  void on_level_start()
  {
    if(@music != null) {
      puts("not null");
      music.stop();
    }
  }

  void step(int) {
    dustman@ dm = controller_entity(0).as_dustman();
    if(@music == null){
      puts(dm.character());
      if(dm.character() == "vdustkid") {
        puts("vdustkid");
        @music = g.play_persistent_stream('music2', 1, true, .75, true);
      } else {
        puts("other");
        @music = g.play_persistent_stream('music1', 1, true, .75, true);
      }
    }
  }
}