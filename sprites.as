const string EMBED_dark0r = "sans/spr_sans_r_dark_0.png";
const string EMBED_dark1r = "sans/spr_sans_r_dark_1.png";
const string EMBED_dark2r = "sans/spr_sans_r_dark_2.png";
const string EMBED_dark3r = "sans/spr_sans_r_dark_3.png";

//const string EMBED_test2 = "test2.png";


class script {
  scene@ g;
  int frame_count;
  sprites@ spr;
  [hidden] int Y1;
  [position,mode:world,layer:19,y:Y1] int X1;
  sansSprite@ sansAnimator;
  array<string>sansWalkR;

  script() {
    array<string>sansWalkR = {"dark0r","dark1r","dark2r","dark3r"};
    @g = get_scene();
    frame_count = 0;
    @spr = create_sprites();
    puts("x1"+X1+" Y1" +Y1);
    @sansAnimator = sansSprite(sansWalkR);
  }

  void build_sprites(message@ msg) {
    msg.set_string("dark0r", "dark0r");
    msg.set_string("dark1r", "dark1r");
    msg.set_string("dark2r", "dark2r");
    msg.set_string("dark3r", "dark3r");
    //msg.set_string("image2", "test2");
  }

  void on_level_start() {
    spr.add_sprite_set("script");
    sansAnimator.setXY(X1, Y1);
  }

  void step(int) { 

  }

  void draw(float subframe) {
    int frame = 1;
    int palette = 1;
    int colour = 0xFFFFFFFF;
    frame_count++;
    sansAnimator.walkRightDark(frame_count, spr);
    
  }
}

class sansSprite {
    array<string> spriteNames;
    int startX, startY;
    int curFrame;
    int colour = 0xFFFFFFFF;
    int speed;
    sansSprite(array<string>sprs) {
        speed = 50;
        spriteNames = sprs;
        startX = 0;
        startY = 0;
        puts("x: "+startX);
        puts("y: "+startY);
        curFrame = 0;
    }

    void setXY(int x, int y) {
        startX = x;
        startY = y;
    }

    void walkRightDark(int frame, sprites@ spr) {
        spr.draw_world(19, 19, spriteNames[curFrame], 0, 1, startX+frame/1.5, (((curFrame+1)%2)*4)+startY,
                0, 3, 3, colour);

        if(frame%speed == 0) {
            curFrame = curFrame + 1 >= spriteNames.size() ? 0 : curFrame+1;
            puts("frame: "+curFrame);
        }

        
        
    }
}