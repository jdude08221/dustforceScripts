const string EMBED_slap1 = "gachi/slap2.ogg";
const string EMBED_slap2 = "gachi/slap3.ogg";
const string EMBED_slap3 = "gachi/slap5.ogg";
const string EMBED_slap4 = "gachi/slap7.ogg";
const string EMBED_slap5 = "gachi/slap6.ogg";
const string EMBED_spikeDeath = "gachi/spikeDeath.ogg";
const string EMBED_hitByEnemy = "gachi/hitByEnemy.ogg";
const string EMBED_boss = "gachi/boss.ogg";
const string EMBED_ahh = "gachi/ahh.ogg";
const string EMBED_pants = "gachi/pants.ogg";
const string EMBED_fuckyou = "gachi/fuckyou.ogg";
const string EMBED_dash = "gachi/dash.ogg";
const string EMBED_jumpair = "gachi/jumpair.ogg";
const string EMBED_jumpwall = "gachi/jumpwall.ogg";
const string EMBED_jumpground = "gachi/jumpground.ogg";
const string EMBED_sayan = "gachi/sayan.ogg";

class script {
  scene@ g;
  uint frames = 0;
  script() {
    @g = get_scene();
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("slap1", "slap1");
    msg.set_string("slap2", "slap2");
    msg.set_string("slap3", "slap3");
    msg.set_string("slap4", "slap4");
    msg.set_string("slap5", "slap5");
    msg.set_string("spikeDeath", "spikeDeath");
    msg.set_string("hitByEnemy", "hitByEnemy");
    msg.set_string("boss", "boss");
    msg.set_string("ahh", "ahh");
    msg.set_string("pants", "pants");
    msg.set_string("fuckyou", "fuckyou");
    msg.set_string("dash", "dash");
    msg.set_string("jumpair", "jumpair");
    msg.set_string("jumpwall", "jumpwall");
    msg.set_string("jumpground", "jumpground");
    msg.set_string("sayan", "sayan");
  }
  
  void on_level_start() {
  /* Overrides the built in sound named "sound" with "override_sound".
   * Any time the game tries to play that sound, the override will be played instead.
   * script_sound indicates whether an embedded, or built in sound will be used for the override */
    // g.override_sound("sfx_impact_heavy_1", "slap1", true);
     //g.override_sound("sfx_impact_heavy_2", "slap2", true);
     //g.override_sound("sfx_impact_heavy_3", "slap3", true);
    //g.play_script_stream("slap1", 3, 0, 0, false, 1);
    g.override_sound("sfx_damage", "hitByEnemy", true);
    g.override_sound("sfx_damage_spikes", "spikeDeath", true);
    g.override_sound("sfx_impact_heavy_1", "slap1", true);
    g.override_sound("sfx_impact_heavy_2", "slap2", true);
    g.override_sound("sfx_impact_heavy_3", "slap3", true);
    g.override_sound("sfx_impact_light_1", "slap4", true);
    g.override_sound("sfx_impact_light_2", "slap5", true);
    g.override_sound("sfx_impact_light_3", "slap5", true);

    g.override_sound("sfx_poly_med", "slap4", true);
    g.override_sound("sfx_poly_heavy", "slap5", true);

    g.override_sound("sfx_dk_special_activate", "fuckyou", true);
    g.override_sound("sfx_dm_special_activate", "fuckyou", true);
    g.override_sound("sfx_dg_special_activate", "fuckyou", true);
    g.override_sound("sfx_do_special_activate", "fuckyou", true);

    g.override_sound("sfx_dk_special_hit", "ahh", true);
    g.override_sound("sfx_dm_special_hit", "ahh", true);
    g.override_sound("sfx_dg_special_hit", "ahh", true);
    g.override_sound("sfx_do_special_hit", "ahh", true);

    g.override_sound("sfx_land_generic_heavy", "pants", true);

    g.override_sound("sfx_dg_dash_air", "dash", true);
    g.override_sound("sfx_dm_dash_air", "dash", true);
    g.override_sound("sfx_do_dash_air", "dash", true);
    g.override_sound("sfx_dk_dash_air", "dash", true);
    
    g.override_sound("sfx_dg_dash_ground", "dash", true);
    g.override_sound("sfx_dm_dash_ground", "dash", true);
    g.override_sound("sfx_do_dash_ground", "dash", true);
    g.override_sound("sfx_dk_dash_ground", "dash", true);
    
    g.override_sound("sfx_dg_fast_fall", "dash", true);
    g.override_sound("sfx_dm_fast_fall", "dash", true);
    g.override_sound("sfx_do_fast_fall", "dash", true);
    g.override_sound("sfx_dk_fast_fall", "dash", true);


    g.override_sound("sfx_dg_jump_air_1", "jumpair", true);
    g.override_sound("sfx_dg_jump_air_2", "jumpair", true);
    g.override_sound("sfx_dg_jump_air_3", "jumpair", true);
    g.override_sound("sfx_dm_jump_air_1", "jumpair", true);
    g.override_sound("sfx_dm_jump_air_2", "jumpair", true);
    g.override_sound("sfx_dm_jump_air_3", "jumpair", true);
    g.override_sound("sfx_dk_jump_air_1", "jumpair", true);
    g.override_sound("sfx_dk_jump_air_2", "jumpair", true);
    g.override_sound("sfx_dk_jump_air_3", "jumpair", true);
    g.override_sound("sfx_do_jump_air_1", "jumpair", true);
    g.override_sound("sfx_do_jump_air_2", "jumpair", true);
    g.override_sound("sfx_do_jump_air_3", "jumpair", true);
    
    g.override_sound("sfx_dg_jump_ground_1", "jumpground", true);
    g.override_sound("sfx_dg_jump_ground_2", "jumpground", true);
    g.override_sound("sfx_dg_jump_ground_3", "jumpground", true);
    g.override_sound("sfx_dm_jump_ground_1", "jumpground", true);
    g.override_sound("sfx_dm_jump_ground_2", "jumpground", true);
    g.override_sound("sfx_dm_jump_ground_3", "jumpground", true);
    g.override_sound("sfx_dk_jump_ground_1", "jumpground", true);
    g.override_sound("sfx_dk_jump_ground_2", "jumpground", true);
    g.override_sound("sfx_dk_jump_ground_3", "jumpground", true);
    g.override_sound("sfx_do_jump_ground_1", "jumpground", true);
    g.override_sound("sfx_do_jump_ground_2", "jumpground", true);
    g.override_sound("sfx_do_jump_ground_3", "jumpground", true);

    g.override_sound("sfx_dg_jump_wall_1", "jumpwall", true);
    g.override_sound("sfx_dg_jump_wall_2", "jumpwall", true);
    g.override_sound("sfx_dg_jump_wall_3", "jumpwall", true);
    g.override_sound("sfx_dm_jump_wall_1", "jumpwall", true);
    g.override_sound("sfx_dm_jump_wall_2", "jumpwall", true);
    g.override_sound("sfx_dm_jump_wall_3", "jumpwall", true);
    g.override_sound("sfx_dk_jump_wall_1", "jumpwall", true);
    g.override_sound("sfx_dk_jump_wall_2", "jumpwall", true);
    g.override_sound("sfx_dk_jump_wall_3", "jumpwall", true);
    g.override_sound("sfx_do_jump_wall_1", "jumpwall", true);
    g.override_sound("sfx_do_jump_wall_2", "jumpwall", true);
    g.override_sound("sfx_do_jump_wall_3", "jumpwall", true);
    g.play_persistent_stream("sayan", 1, true, .65, true);

  }

  void step(int) {
     frames++;

  }

  void on_level_end() {
    g.play_script_stream("boss", 3, 0, 0, false,1);
  }
}
