const string EMBED_sound1 = "ut.ogg"; 
class script : callback_base{
  [entity] int porc;
  bool hit = false;
  int dir = 1;
  audio@ a;
  [text] float speed;
  [text] float rotspeed;
  bool playing = false;
  scene@ g;
  script() {
    @g = get_scene();
  }

  void step(int) {
    entity@ e = entity_by_id(porc);
    if(@e == null || e.as_controllable() == null)
      return;
    e.as_controllable().on_hurt_callback(this,"callback_method", 0);
    e.as_controllable().life(100);

    if(hit) {
      e.x(e.x() + (speed * dir));
      e.y(e.y() - speed);
      e.rotation(e.rotation() + rotspeed);
      if(!playing) {
        playing = true;
        @a = g.play_script_stream("sound1", 2, e.x(), e.y(), true, 2);
        a.positional(true);
      }
      a.set_position(e.x(), e.y());
    }
  }
  
  void build_sounds(message@ msg) {
    msg.set_string("sound1", "sound1");
  }

  void callback_method(controllable@ attacker, controllable@ attacked, hitbox@ attack_hitbox, int arg) {
   hit = true;
   dir = attacker.face();
  }
  void draw(float sub_frame) {
  
  }
}