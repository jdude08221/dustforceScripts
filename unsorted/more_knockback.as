class script : callback_base{
  [text] uint timer;
  dictionary enemies;
  script() {

  }

  void handle_hit_entities() {
    array<string> dict_keys = enemies.getKeys();
    for(uint i = 0; i < dict_keys.size(); i++) {
      flying_corpse@ f = cast<flying_corpse@>(enemies[dict_keys[i]]);
      if(f.removed) {
        enemies.delete(dict_keys[i]);
        return;
      }
      f.step();
    }
  }

  void step(int) {
    handle_hit_entities();
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

  void player_hit_callback(controllable@ attacker, controllable@ attacked, hitbox@ attack_hitbox, int arg) {
    hittable@ h = attacked.as_hittable();
    if(@h == null) {
      return;
    }

    if(h.life() <= attack_hitbox.damage() || attacked.type_name() == "hittable_apple") {
      if(!enemies.exists(''+h.id())) {
        h.life(99);
        flying_corpse@ f = flying_corpse(@attacked, timer, arg, attacker.attack_face(), attack_hitbox.damage());
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
  uint speed = 10;
  uint rotspeed = 10;
  int dir = 0;
  int damage = 1;
  flying_corpse(controllable@ c, uint time, uint p, int d, int dam) {
    @dead_c = @c;
    timer = time;
    player = p;
    @g = get_scene();
    dir = d;
    damage = dam;
    dead = false;
    removed = false;
  }

  void fly() {
    entity@ e = dead_c.as_entity();
    e.x(e.x() + (speed * dir));
    e.y(e.y() - speed);
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
    hb.damage(damage);
    g.add_entity(hb.as_entity());
  }

  void step() {
    if(timer > 0) {
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