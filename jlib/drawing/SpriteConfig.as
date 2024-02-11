class SpriteConfig {
  [text] bool draw_sprite = true;
  [slider,min:-1,max:1] float scalex = 1;
  [slider,min:-1,max:1] float scaley = 1;
  [text] int layer = 18;
  [text] int sublayer = 18;
  [position,mode:world,layer:=layer.3,y:Y1] float X1;
  [hidden] float Y1;
  [angle] float rotation;
  [text] float wobble = 10;
  [text] float speed = 100;
  [hidden] string spriteName = "";
  sprites@ spr = null;

  float theta = 0;
  float update_frame = 0;
  float xofs = 0;
  float yofs = 0;

  SpriteConfig() {

  }

  void init(string name, sprites@ s) {
    spriteName = name;
    @spr = @s;
    if(theta == 0) {
      srand(get_time_us());
      theta = rand();
    }
  }

  void draw() {
    if(!draw_sprite || spriteName == "" || @spr == null) {
      return;
    }
      
    spr.draw_world(layer, sublayer, spriteName, 0, 1, X1 + xofs, Y1 + yofs, rotation, scalex, scaley, 0xFFFFFFFF);
  }

  void update() {
    update_frame++;

    xofs = wobble * cos(theta);
    yofs = wobble * sin(theta);
    theta = (theta + (speed * 3.14159 / 180) / 30) % (3.14159 * 2);
  }
}