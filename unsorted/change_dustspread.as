//Genuinely dont remember if this is my script but im checking it in to keep it :)
class script {
  [option, 0:None, 1:Mansion, 2:Forest, 3:City, 4:Lab] int Spread_Type;
  script() {

  }

  void entity_on_add(entity@ e) {
    filth_ball@ fb = e.as_filth_ball();
    if (@fb == null) {
      return;
    } if (fb.metadata().has_int('ignore')) {
      return;
    } 

    // Choose a random dust type.
    fb.filth_type(Spread_Type);
  }
}