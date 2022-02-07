const string EMBED_music = "dlc2/drip.ogg"; //https://www.youtube.com/watch?v=vdz2yw-gUYc
const string EMBED_music1 = "dlc2/water.ogg";
const string EMBED_music2 = "dlc2/City_of_Tears.ogg";
class script {
  scene@ g;
  audio@ music1;
  [position,mode:world,layer:19,y:Y1] float X1;
  [hidden]float Y1;
  script() {
    @g = get_scene();
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("music", "music"); 
    msg.set_string("music1", "music1"); 
    msg.set_string("music2", "music2");
    msg.set_int("music2|loop", 529200);
  }
  
  void on_level_start() {
    g.play_script_stream('music', 2, 0, 0, true, .15);
    @music1 = g.play_script_stream('music1', 2, X1, Y1, true, .1);
    g.play_persistent_stream("music2", 1, true, .5, true);
    music1.positional(true);
  }
}