class script{
}



class edge_trigger : trigger_base {
    void activate(controllable@ e) {
      puts(e.type_name());

      if(e.type_name() != "enemy_trash_bag") {
        puts(e.id()+"");
        get_scene().remove_entity(entity_by_id(e.id()));
      }

      if(@e.as_dustman()!=null) {
        e.as_dustman().kill(false);
      }
    }
}