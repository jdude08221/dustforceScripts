const string EMBED_prism_light = "dlcweek4/Light_Prism.ogg";
const string EMBED_prism_heavy = "dlcweek4/Heavy_Prism.ogg";

class script
{
  
  scene@ g;
  
  script()
	{
    @g = get_scene();
  }
  
  void build_sounds(message@ msg)
  {
    msg.set_string("prism_light", "prism_light");
    msg.set_string("prism_heavy", "prism_heavy");
  }
  
  void on_level_start()
  {
    g.override_sound("sfx_poly_med", "prism_light",true);
    g.override_sound("sfx_poly_heavy", "prism_heavy",true);
  }
}