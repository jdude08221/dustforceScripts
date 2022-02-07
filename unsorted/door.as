#include "../lib/drawing/Sprite.cpp"
const string EMBED_doorLeft = "door/doorframeleft.png";
const string EMBED_doorRight = "door/doorframeright.png";
const string EMBED_doorWood = "door/doorwood.png";
const string EMBED_doorOutlineL = "door/doorbgleft.png";
const string EMBED_doorOutlineR = "door/doorbgright.png";
class script : callback_base {
    scene@ g;
    sprites@ spr;
    [position,mode:world,layer:20,y:frameLeftY] float frameLeftX;
    [hidden] float frameLeftY;
    [position,mode:world,layer:17,y:frameRightY] float frameRightX;
    [hidden] float frameRightY;
    [position,mode:world,layer:17,y:woodY] float woodX;
    [hidden] float woodY;
    [position,mode:world,layer:17,y:outlineLY] float outlineLX;
    [hidden] float outlineLY;
    [position,mode:world,layer:17,y:outlineRY] float outlineRX;
    [hidden] float outlineRY;
    [text] float scale;
    float openTime;

    bool open;
    bool close;
    script() {
        @g = get_scene();
        add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
        @spr = create_sprites();
        frameLeftX = frameLeftY = frameRightX = frameRightY = woodX = woodY = outlineLX = outlineLY = outlineRX = outlineRY = 0;
        scale = 0;
        open = false;
        close = false;
        openTime = 30;
    }

    void build_sprites(message@ msg) {
        msg.set_string("doorLeft","doorLeft");
        msg.set_string("doorRight","doorRight"); 
        msg.set_string("doorWood","doorWood"); 
        msg.set_string("doorOutlineL","doorOutlineL"); 
        msg.set_string("doorOutlineR","doorOutlineR"); 
    }

    void editor_step() {
      spr.add_sprite_set("script"); 
    }

    void step(int) {
       spr.add_sprite_set("script");
       if(close) {
           if(openTime != 0) {
               openTime--;
           } else {
               open = false;
           }
       }
    }



    void draw(float) {
        spr.draw_world(18, 9, "doorLeft", 0, 1, frameLeftX, frameLeftY, 0, -scale, scale, 0xFFFFFFFF);
        spr.draw_world(18, 13, "doorRight", 0, 1, frameRightX, frameRightY, 0, -scale, scale, 0xFFFFFFFF);
        spr.draw_world(18, 11, "doorWood", 0, 1, woodX, woodY, 0, scale * (open ? 1 : -1), scale, 0xFFFFFFFF);
        spr.draw_world(18, 8, "doorOutlineL", 0, 1, outlineLX, outlineLY, 0, .8, .8, 0xFFFFFFFF);
        spr.draw_world(18, 12, "doorOutlineR", 0, 1, outlineRX, outlineRY, 0, .8, .8, 0xFFFFFFFF);
    }

    void editor_draw(float)
    {
        spr.draw_world(18, 9, "doorLeft", 0, 1, frameLeftX, frameLeftY, 0, -scale, scale, 0xFFFFFFFF);
        spr.draw_world(18, 13, "doorRight", 0, 1, frameRightX, frameRightY, 0, -scale, scale, 0xFFFFFFFF);
        spr.draw_world(18, 11, "doorWood", 0, 1, woodX, woodY, 0, -scale, scale, 0xFFFFFFFF);
        spr.draw_world(18, 8, "doorOutlineL", 0, 1, outlineLX, outlineLY, 0, .8, .8, 0xFFFFFFFF);
        spr.draw_world(18, 12, "doorOutlineR", 0, 1, outlineRX, outlineRY, 0, .8, .8, 0xFFFFFFFF);
    }

    void OnMyCustomEventName(string id, message@ msg) {
        if(msg.get_string('open') == 'true') {  
            //Open door
            open = true;
        } else if(msg.get_string('close') == 'true') {
            //Close door
            close = true;
        }
    }
}

class DoorTrigger : trigger_base, callback_base { 
      
    bool activated;
    bool active_this_frame;
    controllable@ trigger_entity;
    
    void init(script@ s, scripttrigger@ self) {
        activated = false;
        active_this_frame = false;
    }
    
    void rising_edge(controllable@ e) {
        @trigger_entity = @e;
        message@ msg = create_message();
        msg.set_string('open', "true");
        broadcast_message('OnMyCustomEventName', msg); 
    }

    void falling_edge(controllable@ e) {
        @trigger_entity = null;
        message@ msg = create_message();
        msg.set_string('close', "true");
        broadcast_message('OnMyCustomEventName', msg); 
    }
    
    void step() {
        if(activated) {
            if(not active_this_frame) {
                activated = false;
                falling_edge(@trigger_entity);
            }
            active_this_frame = false;
        }
    }
    
    void activate(controllable@ e) {
        if(e.player_index() == 0) {
            if(not activated) {
                rising_edge(@e);
                activated = true;
            }
            active_this_frame = true;
        }
    }
}


