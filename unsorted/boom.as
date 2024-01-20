const string EMBED_boom = "boom.ogg";


class script {
  scene@ g;
  uint frames = 0;
  script() {
    @g = get_scene();
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("boom", "boom");
  }
  
  void on_level_start() {
  /* Overrides the built in sound named "sound" with "override_sound".
   * Any time the game tries to play that sound, the override will be played instead.
   * script_sound indicates whether an embedded, or built in sound will be used for the override */
    // g.override_sound("sfx_impact_heavy_1", "slap1", true);
     //g.override_sound("sfx_impact_heavy_2", "slap2", true);
     //g.override_sound("sfx_impact_heavy_3", "slap3", true);
    //g.play_script_stream("slap1", 3, 0, 0, false, 1);
    g.override_sound("sfx_damage", "boom", true);
    g.override_sound("sfx_damage_spikes", "boom", true);
    g.override_sound("sfx_impact_heavy_1", "boom", true);
    g.override_sound("sfx_impact_heavy_2", "boom", true);
    g.override_sound("sfx_impact_heavy_3", "boom", true);
    g.override_sound("sfx_impact_light_1", "boom", true);
    g.override_sound("sfx_impact_light_2", "boom", true);
    g.override_sound("sfx_impact_light_3", "boom", true);

    g.override_sound("sfx_poly_med", "boom", true);
    g.override_sound("sfx_poly_heavy", "boom", true);

    g.override_sound("sfx_dk_special_activate", "boom", true);
    g.override_sound("sfx_dm_special_activate", "boom", true);
    g.override_sound("sfx_dg_special_activate", "boom", true);
    g.override_sound("sfx_do_special_activate", "boom", true);

    g.override_sound("sfx_dk_special_hit", "boom", true);
    g.override_sound("sfx_dm_special_hit", "boom", true);
    g.override_sound("sfx_dg_special_hit", "boom", true);
    g.override_sound("sfx_do_special_hit", "boom", true);

    g.override_sound("sfx_land_generic_heavy", "boom", true);

    g.override_sound("sfx_dg_dash_air", "boom", true);
    g.override_sound("sfx_dm_dash_air", "boom", true);
    g.override_sound("sfx_do_dash_air", "boom", true);
    g.override_sound("sfx_dk_dash_air", "boom", true);
    
    g.override_sound("sfx_dg_dash_ground", "boom", true);
    g.override_sound("sfx_dm_dash_ground", "boom", true);
    g.override_sound("sfx_do_dash_ground", "boom", true);
    g.override_sound("sfx_dk_dash_ground", "boom", true);
    
    g.override_sound("sfx_dg_fast_fall", "boom", true);
    g.override_sound("sfx_dm_fast_fall", "boom", true);
    g.override_sound("sfx_do_fast_fall", "boom", true);
    g.override_sound("sfx_dk_fast_fall", "boom", true);


    g.override_sound("sfx_dg_jump_air_1", "boom", true);
    g.override_sound("sfx_dg_jump_air_2", "boom", true);
    g.override_sound("sfx_dg_jump_air_3", "boom", true);
    g.override_sound("sfx_dm_jump_air_1", "boom", true);
    g.override_sound("sfx_dm_jump_air_2", "boom", true);
    g.override_sound("sfx_dm_jump_air_3", "boom", true);
    g.override_sound("sfx_dk_jump_air_1", "boom", true);
    g.override_sound("sfx_dk_jump_air_2", "boom", true);
    g.override_sound("sfx_dk_jump_air_3", "boom", true);
    g.override_sound("sfx_do_jump_air_1", "boom", true);
    g.override_sound("sfx_do_jump_air_2", "boom", true);
    g.override_sound("sfx_do_jump_air_3", "boom", true);
    
    g.override_sound("sfx_dg_jump_ground_1", "boom", true);
    g.override_sound("sfx_dg_jump_ground_2", "boom", true);
    g.override_sound("sfx_dg_jump_ground_3", "boom", true);
    g.override_sound("sfx_dm_jump_ground_1", "boom", true);
    g.override_sound("sfx_dm_jump_ground_2", "boom", true);
    g.override_sound("sfx_dm_jump_ground_3", "boom", true);
    g.override_sound("sfx_dk_jump_ground_1", "boom", true);
    g.override_sound("sfx_dk_jump_ground_2", "boom", true);
    g.override_sound("sfx_dk_jump_ground_3", "boom", true);
    g.override_sound("sfx_do_jump_ground_1", "boom", true);
    g.override_sound("sfx_do_jump_ground_2", "boom", true);
    g.override_sound("sfx_do_jump_ground_3", "boom", true);

    g.override_sound("sfx_dg_jump_wall_1", "boom", true);
    g.override_sound("sfx_dg_jump_wall_2", "boom", true);
    g.override_sound("sfx_dg_jump_wall_3", "boom", true);
    g.override_sound("sfx_dm_jump_wall_1", "boom", true);
    g.override_sound("sfx_dm_jump_wall_2", "boom", true);
    g.override_sound("sfx_dm_jump_wall_3", "boom", true);
    g.override_sound("sfx_dk_jump_wall_1", "boom", true);
    g.override_sound("sfx_dk_jump_wall_2", "boom", true);
    g.override_sound("sfx_dk_jump_wall_3", "boom", true);
    g.override_sound("sfx_do_jump_wall_1", "boom", true);
    g.override_sound("sfx_do_jump_wall_2", "boom", true);
    g.override_sound("sfx_do_jump_wall_3", "boom", true);


    g.override_sound("sfx_dg_attack_heavy_1", "boom", true);
    g.override_sound("sfx_dg_attack_heavy_2", "boom", true);
    g.override_sound("sfx_dg_attack_light_1", "boom", true);
    g.override_sound("sfx_dg_attack_light_2", "boom", true);
    g.override_sound("sfx_dg_attack_light_3", "boom", true);

    g.override_sound("sfx_dm_attack_heavy_1", "boom", true);
    g.override_sound("sfx_dm_attack_heavy_2", "boom", true);
    g.override_sound("sfx_dm_attack_light_1", "boom", true);
    g.override_sound("sfx_dm_attack_light_2", "boom", true);
    g.override_sound("sfx_dm_attack_light_3", "boom", true);

    g.override_sound("sfx_dk_attack_heavy_1", "boom", true);
    g.override_sound("sfx_dk_attack_heavy_2", "boom", true);
    g.override_sound("sfx_dk_attack_light_1", "boom", true);
    g.override_sound("sfx_dk_attack_light_2", "boom", true);
    g.override_sound("sfx_dk_attack_light_3", "boom", true);

    g.override_sound("sfx_do_attack_heavy_1", "boom", true);
    g.override_sound("sfx_do_attack_heavy_2", "boom", true);
    g.override_sound("sfx_do_attack_light_1", "boom", true);
    g.override_sound("sfx_do_attack_light_2", "boom", true);
    g.override_sound("sfx_do_attack_light_3", "boom", true);
  }

  void step(int) {
     frames++;

  }
}
