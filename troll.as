const string EMBED_sound1 = "ss.ogg"; 

class script {
    scene@ g;
    audio@ musicHandle;
    int frames;
    script() {
        @g = get_scene();
        @musicHandle = null;
        frames = 0;
    }

    void on_level_start() {
        frames = 0;
        float f = 0;
        float t = 1;
        g.time_warp(t);
    }

    void on_checkpoint_load() {

    }
    void build_sounds(message@ msg) {
        msg.set_string("ss", "sound1");
    }

    void step(int) {
       dustman@ dm = controller_entity(0).as_dustman();
        frames = ((frames+1)%30);
        puts("frames:"+frames);
      // Advance text when light attack is pressed
        if(dm.heavy_intent() == 10) {
            float t = 10;

            g.time_warp(t);
        } else if((dm.heavy_intent() == 11 || dm.heavy_intent() > 0)) {
            frames = 0;
            float t = 10;
            if(@musicHandle == null || !musicHandle.is_playing()) {
                @musicHandle = g.play_script_stream("ss", 2, 0, 0, true, 1);
                
            } else {
                musicHandle.time_scale(1);
            }
            g.time_warp(t);
        } else {
            if(@musicHandle != null && frames == 29) {
                float f = 0;
                float t = 1;
                g.time_warp(t);
                musicHandle.time_scale(f);
            }
        }
    
        

        
    }
}