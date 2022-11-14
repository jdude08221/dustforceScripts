  const dictionary V_ATTACK_DIRS = {
    { "groundstrikeu1", 1 },
    { "groundstrikeu2", 1 },
    { "groundstriked", -1 },
    { "groundstrike1", 0},
    { "groundstrike2", 0 },
    { "heavyu", 1 },
    { "heavyd", -1 },
    { "heavyf", 0 },

    { "airstriked1", -1 },
    { "airstriked2", -1},
    { "airheavyd", -1 }
  };

class script : callback_base {
  [text] uint timer;
  dictionary enemies;
  dictionary bounced_enemies;
  scene@ g;
  int attackDir = 2;
  bool play_impact_heavy = false;
  bool play_impact_light = false;


  script() {
    @g = get_scene();
  }

  void handle_hit_entities() {
    array<string> dict_keys = enemies.getKeys();
    for(uint i = 0; i < dict_keys.size(); i++) {
      flying_corpse@ f = cast<flying_corpse@>(enemies[dict_keys[i]]);

      if(bounced_enemies.exists(""+f.dead_c.as_entity().id())) {
        bounced_enemies.delete(""+f.dead_c.as_entity().id());
        f.kill = true;
      }

      if(f.removed) {
        enemies.delete(dict_keys[i]);
        continue;
      }

      //We need to give one frame of leniency to get the attack direction
      if(!f.setup) {
        f.step();
        continue;
      }

      //Set what direciton the prism should go, wont work in multiplayer 100%
      if(!f.dirset && attackDir != 2) {
        f.dirset = true;
        f.diry = attackDir;
      }

      f.step();
    }
  }

  void step(int) {
    handle_hit_entities();
    if(play_impact_heavy) {
      g.play_sound("sfx_impact_heavy_1", 3, 0, 1, false, false);
      g.play_sound("sfx_poly_heavy", 3, 0, 1, false, false);
      play_impact_heavy = false;
    } else if(play_impact_light) {
      g.play_sound("sfx_poly_med", 3, 0, 1, false, false);
      play_impact_light = false;
    }

    for(uint i = 0; i < 4; i++) {
      dustman@ dm;
    
      if(@controller_entity(i) != null && @controller_entity(i).as_dustman() != null) {
        @dm = controller_entity(i).as_dustman();
      } else {
        return;
      }
      dm.on_hit_callback(this, "player_hit_callback", i);
    }
  }

  void entity_on_add(entity@ e) {
    if(e.type_name() == "effect") {
      string effect_name_suffix = e.sprite_index().substr(2);
      
      if(V_ATTACK_DIRS.exists(effect_name_suffix)) {
        attackDir = int(V_ATTACK_DIRS[effect_name_suffix]);
      }
    }
  }

  void bounce_collision_callback(controllable@ ec, tilecollision@ tc, int side, bool moving, float snap_offset, int arg) {
    ec.check_collision(tc, side, moving, snap_offset);
    if(tc.hit() && ec.type_name() != "hittable_apple") {
      bounced_enemies[""+ec.id()] = true;
    }
  }

  void player_hit_callback(controllable@ attacker, controllable@ attacked, hitbox@ attack_hitbox, int arg) {
    hittable@ h = attacked.as_hittable();
    if(@h == null) {
      return;
    }

    if(h.life() <= attack_hitbox.damage() || attacked.type_name() == "hittable_apple") {
      uint damage = attack_hitbox.damage();

      if(!enemies.exists(''+h.id())) {
        //Large prisms die automatically if the damage is 3, no matter what their life is
        attacked.set_collision_handler(this, "bounce_collision_callback", 0);
        if(attacked.type_name() == "enemy_tutorial_hexagon") {
          play_impact_heavy = attack_hitbox.damage() == 3;
          play_impact_light = attack_hitbox.damage() == 1;
          attack_hitbox.damage(0);
        }
        h.life(99);
        flying_corpse@ f = flying_corpse(@attacked, timer, arg, attacker.attack_face(), damage);
        enemies[''+h.id()] = @f;
      }
    }
  }
}

class flying_corpse {
  controllable@ dead_c;
  scene@ g;
  uint timer = 0;
  bool dead = false;
  bool removed = false;
  uint player = 0;
  float speed = 15;
  float rotspeed = 20;
  int dirx = 0;
  int diry  = 0;
  int damage = 1;
  bool dirset = false;
  bool setup = false;
  bool kill = false;
  bool offset = false;
  flying_corpse(controllable@ c, uint time, uint p, int d, int dam) {
    @dead_c = @c;
    timer = time;
    player = p;
    @g = get_scene();
    dirx = d;
    damage = dam;
    dead = false;
    removed = false;
  }

  void fly() {
    entity@ e = dead_c.as_entity();

    if(!offset) {
      offset = true;
      if(diry != 0) {
        float newspeed = e.y() + (float(diry) * speed * 5);
        puts(newspeed+"");
        e.y(newspeed);
      }
      e.x(e.x() - (dirx * speed * 6.4));
    }

    e.x(e.x() + (speed * dirx));
    dead_c.set_speed_xy(0,0);
    float delta_y = diry == 0 ? e.y() - speed/2: e.y() - (speed * diry);
    e.y(delta_y);
    e.rotation(e.rotation() + rotspeed);
      //if(!playing) {
        //playing = true;
        //@a = g.play_script_stream("sound1", 2, e.x(), e.y(), true, 2);
        //a.positional(true);
      //}
      //a.set_position(e.x(), e.y());
  }

  void die() {
    controllable@ c;
  
    if(@controller_entity(0) != null && @controller_entity(0).as_controllable() != null) {
      @c = controller_entity(0).as_controllable();
    } else {
      g.remove_entity(dead_c.as_entity());
      return;
    }

    hittable@ h = dead_c.as_hittable();
    if(@h == null) {
      return;
    }
    
    //Do not spawn another hitbox on apples as they cant die
    if(dead_c.type_name() == "hittable_apple") {
      return;
    }
    //Set enemy's life to -1 and spawn a hitbox to clean it. Use whatever attack type dustman used
    h.life(-1);
    hitbox@ hb = create_hitbox(@c, 0, dead_c.x(), dead_c.y(), -1, 1, -1, 1);
    hb.damage(1);
    g.add_entity(hb.as_entity());
  }

  void step() {
    entity@ e = dead_c.as_entity();
    if(!setup) {
      setup = true;
      //Move entity slightly off surface to avoid clipping
    } else if(timer > 0 && !kill) {
      fly();
      timer--;
    } else if(!dead) {
      die();
      dead = true;
    } else {
      removed = true;
    }
  }
}