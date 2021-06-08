#include "../lib/math/Line.cpp";
#include "../lib/props/common.cpp"
#include "../lib/drawing/Sprite.cpp"
#include "../lib/drawing/common.cpp"
#include '../lib/ui/prop-selector/PropSelector.cpp';
#include '../Alex/prop_group.as';

const string EMBED_spr1 = "propRail/spr1.png"; 
const string EMBED_spr2 = "propRail/spr2.png"; 
const string EMBED_spr3 = "propRail/spr3.png"; 
const string EMBED_spr4 = "propRail/spr4.png";

const int BASE_SPAWN_RATE = 8000;
const int NUM_SPRITES = 4;
const uint WHITE = 0xFFFFFFFF; 
const uint GREEN = 0xFF00FF00; 
const uint WHITE_TRANSPARENT = 0x4AFFFFFF; 
const uint GREEN_TRANSPARENT = 0x4A00FF00; 
//18-i is scaled at (1-0.05*i) for 18-i >5
//1<=i<=5 has scale 0.05i might be scaled down by another 1/16th

//TODO: use prop_group.as and wiggle.as to allow for custom props to be used
//TODO: update how trigger handle x/y position is set so it isnt obnoxious (moves to 0,0 always)
//TODO: add wrapping on the rail instead of bouncing

class script : callback_base {
  [text]array<SpawnHelper@> spawnArr;
  scene@ g;
  int frameCount;
  sprites@ spr;
  bool exists = false;
  bool s_drawSprites;
  [hidden]int s_layer, s_sublayer, s_palette;
  [hidden]float s_x1, s_y1, s_x2, s_y2, s_startingRotation, s_scalePropX, s_scalePropY, s_rotationSpeed;
  [hidden]bool s_rotateClockwiseOnly, s_rotateCounterClockwiseOnly;
  [hidden]string s_spriteName;
  [hidden]Sprite spr1, spr2;

  script() {
    frameCount = 0;
    @g = get_scene();
    srand(timestamp_now());
    @spr = create_sprites();
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    //override_stream_sizes(100, 8);
  }

    void build_sprites(message@ msg) {
      msg.set_string("spr1","spr1");
      msg.set_string("spr2","spr2"); 
      msg.set_string("spr3","spr3"); 
      msg.set_string("spr4","spr4"); 
  }

  void on_level_start() {
    spr.add_sprite_set("script");
  }
  void draw(float subframe) {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      if(sh.isSprite) {
        spr1.set(sh.spriteSet, sh.spriteName);
        spr1.draw(sh.layer, sh.sublayer, 0, sh.palette, sh.sprx, 
              sh.spry, sh.sprRotation, sh.scaleX, sh.scaleY, WHITE);
      }
    }
  }
  void step(int entities) {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      
      if(!sh.exists) {
        sh.exists = true;
      }

      bool lineDefined = sh.X1 != sh.X2;
      Line propPath(sh.X1, sh.Y1, sh.X2, sh.Y2);
      if(frameCount % sh.frameSkip == 0 && continueLaps(sh)) { // If this isnt a skipped frame AND we havent completed our lap count, update sprite position/rotation
        if(lineDefined && (sh.sprx >= sh.maxX || sh.sprx <= sh.minX)) {
          flipDirectionSpr(sh, sh.sprx >= sh.maxX ? -1 : 1);
        } else if(lineDefined) {
            sh.sprx = sh.sprx + (sh.speed * sh.direction);
            sh.spry = propPath.getY(sh.sprx) + sh.wobbleAmplitude * sin(sh.wobbleSpeed * frameCount / 20.0);
        } else if(!lineDefined && (sh.spry >= sh.maxY || sh.spry <= sh.minY)){
          flipDirectionSpr(sh, sh.spry >= sh.maxY ? -1 : 1);
        } else {
          sh.spry = (sh.spry+ (sh.speed * sh.direction) + sh.wobbleAmplitude * sin((sh.wobbleSpeed * frameCount / 20.0)));
          sh.sprx = sh.sprx;
        }
        rotateSprite(sh);
      } else if(frameCount % sh.frameSkip == 0) { // If this isnt a skipped frame and the sprite has completed all of its laps, stop moving along the path
        //Record the final y value for a smooth wobble
        if(sh.Y1 != 0 && sh.Y2 != 0 && sh.finalY == 0) {
          sh.finalY = sh.spry;
        }
        sh.spry = sh.finalY+ sh.wobbleAmplitude * sin(sh.wobbleSpeed * frameCount / 20.0);
        rotateSprite(sh);
      }
    }
    frameCount++;
  }
  
  bool continueLaps(SpawnHelper@ sh) {
    return !sh.runNTimes || (sh.runNTimes && sh.numLaps >= 0);
  }

  void rotateSprite(SpawnHelper@ sh) {
    if(sh.rotateClockwiseOnly) {
      sh.sprRotation = sh.sprRotation + sh.rotationSpeed;
      return;
    } else if(sh.rotateCounterClockwiseOnly) {
      sh.sprRotation = sh.sprRotation - sh.rotationSpeed;
      return;
    }

    //If we are at the end of a rotation cycle and the pause timer still has time left,
    if(((sh.sprRotation >= sh.startingRotation + sh.rotationClockwise) || 
    (sh.sprRotation <= sh.startingRotation - sh.rotationCounterClockwise)) &&
    (sh.pauseTimer > 0)) {
      //Decrement the timer and return in order to NOT rotate the prop for pauseTimer# frames
      sh.pauseTimer--;
      return;
    } else {
      sh.pauseTimer = sh.rotationPause;
    }

    sh.sprRotation = sh.sprRotation + (sh.rotationSpeed * sh.rotationDir);
    //If the current rotation exceeds the desired rotation, swap directions;
    if(sh.sprRotation >= sh.startingRotation + sh.rotationClockwise) {
      sh.sprRotation = sh.startingRotation + sh.rotationClockwise;
      sh.rotationDir *= -1;
    } else if (sh.sprRotation <= (sh.startingRotation - sh.rotationCounterClockwise)) {
      sh.sprRotation = sh.startingRotation - sh.rotationCounterClockwise;
      sh.rotationDir *= -1;
    }
  }

  void flipDirectionSpr(SpawnHelper@ sh, int dir) {
    Line propPath(sh.X1, sh.Y1, sh.X2, sh.Y2);
    bool lineDefined = sh.X1 != sh.X2;
    // Change direction of movement and start moving other way
    sh.direction = dir;

    // Flip the prop if needed for X/Y
    sh.scaleX = sh.flipx ? -1 * sh.scaleX : sh.scaleX;
    sh.scaleY = sh.flipy ? -1 * sh.scaleY : sh.scaleY;

    if(lineDefined) {
      sh.sprx = sh.sprx + (sh.speed * sh.direction);
      sh.spry = propPath.getY(sh.sprx) + sh.wobbleAmplitude * sin((sh.wobbleSpeed * frameCount / 20.0));
    } else {
      sh.spry = (sh.speed * sh.direction) + sh.spry + sh.wobbleAmplitude * sin((sh.wobbleSpeed * frameCount / 20.0));
    }
    

    // Decrement lap count
    sh.numLaps--;
  }

  void checkpoint_save() { }

  void checkpoint_load() { }
  
  void editor_step() {
    spr.add_sprite_set("script");
  }

  void editor_draw(float sub_frame) {
    //draw sprite preview
    if(s_drawSprites){
      spr1.set("script", s_spriteName);
      spr2.set("script", s_spriteName);

      spr1.draw(s_layer, s_sublayer, 0, 1, s_x1, 
                s_y1, s_startingRotation, s_scalePropX, s_scalePropY, WHITE);
      spr2.draw(s_layer, s_sublayer, 0, 1, s_x2, 
                s_y2, s_startingRotation, s_scalePropX, s_scalePropY, WHITE);
    }
  }

  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('triggerType') == 'propRail') {
      SpawnHelper@ tmpSH = SpawnHelper();
      // Yeah I should have used a dictionary
      for(uint i = 0; i < spawnArr.length(); i++) {
        if(msg.get_string('triggerID') == spawnArr[i].triggerID) {
          return;
        }
      }
      tmpSH.speed = msg.get_int('speed');
      tmpSH.layer = msg.get_int('layer');
      tmpSH.sublayer = msg.get_int('sublayer');
      tmpSH.runNTimes = msg.get_int('runNTimes') == 1;
      tmpSH.flipx = msg.get_int('flipx') == 1;
      tmpSH.flipy = msg.get_int('flipy') == 1;
      tmpSH.isSprite = msg.get_int('isSprite') == 1;
      tmpSH.spriteName = msg.get_string('spriteName');
      tmpSH.spriteSet = msg.get_string('spriteSet');
      tmpSH.set = msg.get_int('set');
      tmpSH.group = msg.get_int('group');
      tmpSH.index = msg.get_int('index');
      tmpSH.palette = msg.get_int('palette');
      tmpSH.start = msg.get_int('start');
      tmpSH.numLaps = msg.get_int('numLaps');
      tmpSH.frameSkip = msg.get_int('frameSkip');
      tmpSH.wobbleAmplitude = msg.get_int('wobbleAmplitude');
      tmpSH.wobbleSpeed = msg.get_int('wobbleSpeed');
      tmpSH.setStart(tmpSH.start);
      tmpSH.maxX = msg.get_float('maxX');
      tmpSH.minX = msg.get_float('minX');
      tmpSH.maxY = msg.get_float('maxY');
      tmpSH.minY = msg.get_float('minY');
      tmpSH.X1 = msg.get_float('X1');
      tmpSH.X2 = msg.get_float('X2');
      tmpSH.Y1 = msg.get_float('Y1');
      tmpSH.Y2 = msg.get_float('Y2');
      tmpSH.scaleX = msg.get_float('scaleX');
      tmpSH.scaleY = msg.get_float('scaleY');
      tmpSH.startingRotation = msg.get_float('startingRotation');
      tmpSH.rotationSpeed = msg.get_float('rotationSpeed');
      tmpSH.rotationClockwise = msg.get_float('rotationClockwise');
      tmpSH.rotationCounterClockwise = msg.get_float('rotationCounterClockwise');
      tmpSH.triggerID = msg.get_string('triggerID');
      tmpSH.rotationDir = 1;
      tmpSH.sprRotation = tmpSH.startingRotation;
      tmpSH.rotationPause = msg.get_int('rotationPause');
      tmpSH.pauseTimer = 0;
      tmpSH.rotateClockwiseOnly = msg.get_int('rotateClockwiseOnly') == 1;
      tmpSH.rotateCounterClockwiseOnly = msg.get_int('rotateCounterClockwiseOnly') == 1;

      if(tmpSH.start == 1) {// If left to right
        if(tmpSH.X1 != tmpSH.X2) {// Not vertical line
          tmpSH.sprx = tmpSH.X1 > tmpSH.X2 ? tmpSH.X2 : tmpSH.X1;
          tmpSH.spry = tmpSH.X1 > tmpSH.X2 ? tmpSH.Y2 : tmpSH.Y1;
        } else { // Vertical line
          tmpSH.sprx = tmpSH.X1;
          tmpSH.spry = tmpSH.Y1 > tmpSH.Y2 ? tmpSH.Y1 : tmpSH.Y2;
        }
      } else {
        if(tmpSH.X1 != tmpSH.X2) {// Not vertical line
          tmpSH.sprx = tmpSH.X1 > tmpSH.X2 ? tmpSH.X1 : tmpSH.X2;
          tmpSH.spry = tmpSH.X1 > tmpSH.X2 ? tmpSH.Y1 : tmpSH.Y2;
        } else { // Vertical line
          tmpSH.sprx = tmpSH.X1;
          tmpSH.spry = tmpSH.Y1 > tmpSH.Y2 ? tmpSH.Y2 : tmpSH.Y1;
        }
      }

      spawnArr.insertLast(tmpSH);
    } else if(msg.get_int('s_drawSprites') == 1) { // Message to draw editor preview of custom sprite
      s_drawSprites = msg.get_int('s_drawSprites') == 1;
      s_layer = msg.get_int('s_layer');
      s_sublayer = msg.get_int('s_sublayer');
      s_palette = msg.get_int('s_palette');
      s_x1 = msg.get_float('s_x1');
      s_y1 = msg.get_float('s_y1');
      s_x2 = msg.get_float('s_x2');
      s_y2 = msg.get_float('s_y2');
      s_startingRotation = msg.get_float('s_startingRotation');
      s_scalePropX = msg.get_float('s_scalePropX');
      s_scalePropY = msg.get_float('s_scalePropY');
      s_spriteName = msg.get_string('s_spriteName');
    } else if(msg.get_int('s_drawSprites') == 2) {
      s_drawSprites = false;
    }
  }
}



class RailTrigger : trigger_base, callback_base {
  [tooltip:"Opens prop selector. Be sure IsCustomSprite is off when using\nprops.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]
  [text] bool selectProp;
  [text]bool showLines;
  [text|tooltip:"Enable this if you are using a custom sprite. Be sure to\nspecify a SpriteName as well.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]bool isCustomSprite;
  [option,0:None, 1:spr1.png,2:spr2.png,3:spr3.png,4:spr4.png|tooltip:"Set this to your sprite name if you have IsCustomSprite on.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int spriteName;
  [text|tooltip:"Background layers (1-5) are buggy. Use at your own risk.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int layer;
  [text]int sublayer;
  [text|tooltip:"Increase value to make some movements slower. Will make movement\nmore choppy though.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int frameSkip;
  [position,mode:world,layer:18,y:Y1] float X1;
  [position,mode:world,layer:18,y:Y2] float X2;
  [option,0:Right,1:Left|tooltip:"Which side prop / sprite should start on. In cases of a verticle\nline, arrow does not represent direction of movement (bug).",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] int start;
  [text|tooltip:"Speed, measured in units/frame, object moves along line.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int speed;
  [text|tooltip:"When set to true, object will flip over the x-axis upon reaching\nthe end of a rail.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]bool flipx;
  [text|tooltip:"When set to true, object will flip over the y-axis upon reaching\nthe end of a rail.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]bool flipy;
  [text|tooltip:"When set to true, object hit the end of the rail\nnumLaps# of times then stop.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]bool runNTimes;
  [text|tooltip:"See RunNTimes.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int numLaps;
  [text|tooltip:"Set this alongside WobbleSpeed to have object wobble/bounce.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int wobbleAmplitude;
  [text|tooltip:"See wobbleAmplitude",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF]int wobbleSpeed;
  [text] float scalePropX;
  [text] float scalePropY;
  [angle] float startingRotation;
  [text|tooltip:"Angle (in degrees) that an object will rotate clockwise before\nrotating back counter-clockwise.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] float rotationClockwise;
  [text|tooltip:"Angle (in degrees) that an object will rotate counter-clockwise\nbefore rotating back clockwise.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] float rotationCounterClockwise;
  [text|tooltip:"Speed, measured in degrees/frame, that an object will rotate.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] float rotationSpeed;
  [text|tooltip:"Time, measured in frames, that an object will NOT rotate\nupon reaching its max clockwise or counter-clockwise rotation.\nBasically a delay.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] int rotationPause;
  [text|tooltip:"Set object to only rotate clockwise.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] bool rotateClockwiseOnly;
  [text|tooltip:"Set object to only rotate counter-clockwise.",delay:20,font:sans_bold,size:20,colour/color:0xFFFFFFFF] bool rotateCounterClockwiseOnly;

  [hidden] float Y1, Y2;
  [hidden] float Y1Backup;
  [hidden] bool sendMessage;
  [hidden] float maxX, minX, maxY, minY;
  [hidden] float scale;
  [hidden] float tMaxX, tMaxY, tMinX, tMinY;
  [hidden] float tX1, tY1, tX2, tY2;
  [hidden] float realX1, realY1, realX2, realY2;
  [hidden]string name;
  [hidden]int prop_set;
  [hidden]int prop_group;
  [hidden]int prop_index;
  [hidden]int prop_palette;
  [hidden]bool drawSpriteEditor;

  [hidden] float previewRotation;
  [hidden] int rotationDir, previewRotationDir;
  [hidden] string sprSet, sprName;
  [hidden] int frameCount;
  [hidden] int pauseTimer;
  scene@ g;

  private UI@ ui = UI();
  private Mouse@ mouse = ui.mouse;
  private PropSelector prop_selector(ui);

  scripttrigger@ self;
  Sprite spr1, spr2;

  RailTrigger() {
    selectProp = false;
    @g = get_scene();
    speed = 5;
    layer = sublayer = 15;
    showLines = true;
    X1 = Y1 = X2 = Y2 = 0;
    realX1 = realY1 = realX2 = realY2 = 0;
    scale = 1;
    sendMessage = true;
    name = "railTrigger";
    start = 1;
    add_broadcast_receiver('OnMyCustomEventNameAck', this, 'OnMyCustomEventNameAck');
    scalePropX = 1.0f;
    scalePropY = 1.0f;
    numLaps = 0;
    frameCount = 0;
    drawSpriteEditor = false;
    isCustomSprite = false;
    rotationSpeed = 0;
    rotationClockwise = 0;
    rotationCounterClockwise = 0;
    rotateClockwiseOnly = false;
    rotateCounterClockwiseOnly = false;
    rotationDir = 1;
    previewRotation = 0;
    previewRotationDir = 1;
    rotationPause = 0;
    pauseTimer = rotationPause;
  }

  void init(script@ s, scripttrigger@ self ) {
    @this.self = @self;
    name = "railTrigger" + self.as_entity().id();
    Y1 = Y1Backup;
    getMaxMinXY();
    getScale();
    scaleXY();

    if(!isCustomSprite) {
      sprite_from_prop(prop_set, prop_group, prop_index, sprSet, sprName);
      spr1.set(sprSet, sprName);
      spr2.set(sprSet, sprName);
      spr1.real_position(X1, Y1, startingRotation, realX1, realY1, scalePropX, scalePropY);
      spr2.real_position(X2, Y2, startingRotation, realX2, realY2, scalePropX, scalePropY);
    }
    //puts('realX1: '+realX1+"realY1: "+realY1);
  }

  void editor_draw(float sub_frame) {
    if(prop_selector.visible)
    {
      prop_selector.draw();
      
      if(prop_selector.result == Selected)
      {
        if(prop_selector.result_prop is null) {
          prop_set = 0;
          prop_index = 0;
          prop_group = 0;
          prop_palette = 0;
        } else {
          prop_set = prop_selector.result_prop.set;
          prop_index = prop_selector.result_prop.index;
          prop_group = prop_selector.result_prop.group;
          prop_palette = prop_selector.result_palette;
        }
        
        prop_selector.hide();
      }
      else if(prop_selector.result == None)
      {
        prop_set = 0;
        prop_index = 0;
        prop_group = 0;
        prop_palette = 0;
        prop_selector.hide();
      }
    }

    if(showLines) {
        //Lines need to be adjusted depending on if X1 > X2, due to that effecting what direction left or right is from the point
        if(start == 1) {
          if(X1 < X2) {
            draw_arrow(g, 21, 10, X1, Y1, (X2+X1) / 2, (Y2+Y1)/2, 2, 30, 1, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
            g.draw_line_world(21, 10, X2, Y2, (X2+X1) / 2, (Y2+Y1)/2, 5, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
          } else {
            draw_arrow(g, 21, 10, X2, Y2, (X2+X1) / 2, (Y2+Y1)/2, 2, 30, 1, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
            g.draw_line_world(21, 10, X1, Y1, (X2+X1) / 2, (Y2+Y1)/2, 5, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
          }
        } else {
          if(X1 < X2) {
            draw_arrow(g, 21, 10, X2, Y2, (X2+X1) / 2, (Y2+Y1)/2, 2, 30, 1, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
            g.draw_line_world(18, 10, X1, Y1, (X2+X1) / 2, (Y2+Y1)/2, 5, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
          } else {
            draw_arrow(g, 21, 10, X1, Y1, (X2+X1) / 2, (Y2+Y1)/2, 2, 30, 1, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
            g.draw_line_world(18, 10, X2, Y2, (X2+X1) / 2, (Y2+Y1)/2, 5, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
          }
          
        }
        g.draw_line_world(layer, 10, tX1, tY1, tX2, tY2, 5, this.self.editor_selected() ? WHITE : WHITE_TRANSPARENT);
        Y1Backup = Y1;
        drawProps();
    }
  }
  void drawProps() {
    if(!isCustomSprite) {
      //Draw the prop preview with wobble
      spr1.draw(layer, sublayer, 0, prop_palette, tX1, tY1 + wobbleAmplitude * sin((wobbleSpeed * frameCount / 20.0)), previewRotation, scalePropX, scalePropY, WHITE);
      spr2.draw(layer, sublayer, 0, prop_palette, tX2, tY2 + wobbleAmplitude * sin((wobbleSpeed * frameCount / 20.0)), previewRotation, scalePropX, scalePropY, WHITE);
    }
  }

  void editor_step() {
    ui.step();
    getMaxMinXY();
    getScale();
    scaleXY();

    // If the user has selected to draw a custom sprite, script() needs to handle the drawing
    if(isCustomSprite) {
      //Send message to script() in order to draw sprite preview
      message@ msg = create_message();
      msg.set_int('s_drawSprites', isCustomSprite ? 1:2);
      msg.set_int('s_layer', layer);
      msg.set_int('s_sublayer', sublayer);
      msg.set_int('s_palette', prop_palette);

      msg.set_int('s_rotateClockwiseOnly', rotateClockwiseOnly? 1:0);
      msg.set_int('s_rotateCounterClockwiseOnly', rotateCounterClockwiseOnly ? 1:0);
      msg.set_float('s_rotationSpeed', rotationSpeed);
      msg.set_float('s_x1', tX1);
      msg.set_float('s_y1', tY1 + wobbleAmplitude * sin((wobbleSpeed * frameCount / 20.0)));
      msg.set_float('s_x2', tX2 );
      msg.set_float('s_y2', tY2 + wobbleAmplitude * sin((wobbleSpeed * frameCount / 20.0)));
      
      //msg.set_float('s_startingRotation', startingRotation);
      msg.set_float('s_scalePropX', scalePropX);
      msg.set_float('s_scalePropY', scalePropY);
      msg.set_string('s_spriteName', 'spr'+spriteName);
      if(rotateClockwiseOnly) {
        previewRotation = previewRotation + rotationSpeed;
      } else if(rotateCounterClockwiseOnly) {
        previewRotation = previewRotation - rotationSpeed;
      } else {
        frameSkip = frameSkip == 0 ? 1 : frameSkip;
          if(frameCount % frameSkip == 0) {
            if(((previewRotation >= startingRotation + rotationClockwise) || 
              (previewRotation <= startingRotation - rotationCounterClockwise)) &&
              (pauseTimer > 0)) {
                previewRotation = previewRotation;
                pauseTimer--;
            } else {
              pauseTimer = rotationPause;
              previewRotation = previewRotation + rotationSpeed * previewRotationDir;
              if(previewRotation >= startingRotation + rotationClockwise) {
                previewRotation = startingRotation + rotationClockwise;
                previewRotationDir *= -1;
              } else if(previewRotation <= startingRotation - rotationCounterClockwise) {
                previewRotation = startingRotation - rotationCounterClockwise;
                previewRotationDir *= -1;
              }
            }
          }
      }
      msg.set_float('s_startingRotation', previewRotation);
      broadcast_message('OnMyCustomEventName', msg);
    } else { // User has selected to use a prop, get the prop's sprite and draw it
      message@ msg = create_message();
      msg.set_int('s_drawSprites', isCustomSprite ? 1:2);
      broadcast_message('OnMyCustomEventName', msg);
      sprite_from_prop(prop_set, prop_group, prop_index, sprSet, sprName);
      spr1.set(sprSet, sprName);
      spr2.set(sprSet, sprName);
      spr1.real_position(X1, Y1, startingRotation, realX1, realY1, scalePropX, scalePropY);
      spr2.real_position(X2, Y2, startingRotation, realX2, realY2, scalePropX, scalePropY);

      if(rotateClockwiseOnly) {
        previewRotation = previewRotation + rotationSpeed;
      } else if(rotateCounterClockwiseOnly) {
        previewRotation = previewRotation - rotationSpeed;
      } else {
        if(((previewRotation >= startingRotation + rotationClockwise) || 
          (previewRotation <= startingRotation - rotationCounterClockwise)) &&
          (pauseTimer > 0)) {
             previewRotation = previewRotation;
             pauseTimer--;
        } else {
          pauseTimer = rotationPause;
          previewRotation = previewRotation + rotationSpeed * previewRotationDir;
          if(previewRotation >= startingRotation + rotationClockwise) {
            previewRotation = startingRotation + rotationClockwise;
            previewRotationDir *= -1;
          } else if(previewRotation <= startingRotation - rotationCounterClockwise) {
            previewRotation = startingRotation - rotationCounterClockwise;
            previewRotationDir *= -1;
          }
        }
      }
    }

    self.set_xy((X1 + X2)/2, (Y1 + Y2)/2);
    
    if(!prop_selector.visible && selectProp)
    {
      prop_selector.select_group(null);
      prop_selector.select_prop(null);
      
      if(/*@brush_def.selected_prop != null*/true)
      {
        prop_selector.select_prop(prop_set, prop_group, prop_index, prop_palette);
      }
      else
      {
        prop_selector.select_prop(null);
      }
      prop_selector.show();
      selectProp = false;
      self.editor_sync_vars_menu();
    }
    //puts('realX1: '+realX1+"realY1: "+realY1);
    frameCount++;
  }

  void step() {
    if(sendMessage) {
      message@ msg = create_message();
      msg.set_string('triggerID', name);
      msg.set_string('triggerType', 'propRail');
      msg.set_int('speed', speed);
      msg.set_int('layer', layer);
      msg.set_int('sublayer', sublayer);
      msg.set_int('set', prop_set);
      msg.set_int('group', prop_group);
      msg.set_int('index', prop_index);
      msg.set_int('palette', prop_palette);
      msg.set_int('start', start);
      msg.set_int('runNTimes', runNTimes ? 1:0);

      if(isCustomSprite) {
        msg.set_string('spriteName', 'spr'+spriteName);
        msg.set_string('spriteSet', 'script');
      } else {
        msg.set_string('spriteName', sprName);
        msg.set_string('spriteSet', sprSet);
      }

      msg.set_int('isSprite', 1);
      msg.set_int('numLaps', numLaps);
      msg.set_int('flipx', flipx ? 1:0);
      msg.set_int('flipy', flipy ? 1:0);
      msg.set_int('frameSkip', frameSkip == 0 ? 1 : frameSkip);
      msg.set_int('wobbleAmplitude', wobbleAmplitude);
      msg.set_int('wobbleSpeed', wobbleSpeed);
      //if(layer <= 5) {
        realX1 = tX1;
        realX2 = tX2;
        realY1 = tY1;
        realY2 = tY2;
      //}
      if(layer > 5 ) {
        msg.set_float('maxX', realX1 > realX2? realX1:realX2);
        msg.set_float('minX', realX1 > realX2? realX2:realX1);
        msg.set_float('maxY', realY1 > realY2? realY1:realY2);
        msg.set_float('minY', realY1 > realY2? realY2:realY1);
        msg.set_float('X1', realX1);
        msg.set_float('X2', realX2);
        msg.set_float('Y1', realY1);
        msg.set_float('Y2', realY2);
      } else {
        msg.set_float('maxX', tX1 > tX2? tX1:tX2);
        msg.set_float('minX', tX1 > tX2? tX2:tX1);
        msg.set_float('maxY', tY1 > tY2? tY1:tY2);
        msg.set_float('minY', tY1 > tY2? tY2:tY1);
        msg.set_float('X1', tX1);
        msg.set_float('X2', tX2);
        msg.set_float('Y1', tY1);
        msg.set_float('Y2', tY2);
      }
      
      msg.set_float('scaleX', flipx ? -1 * scalePropX : scalePropX);
      msg.set_float('scaleY', flipy ? -1 * scalePropY : scalePropY);
      msg.set_float('startingRotation', startingRotation);
      msg.set_float('rotationSpeed', rotationSpeed);
      msg.set_int('rotationPause', rotationPause);
      msg.set_float('rotationClockwise', rotationClockwise);
      msg.set_float('rotationCounterClockwise', rotationCounterClockwise);
      msg.set_int('rotateClockwiseOnly', rotateClockwiseOnly ? 1:0);
      msg.set_int('rotateCounterClockwiseOnly', rotateCounterClockwiseOnly ? 1:0);
      broadcast_message('OnMyCustomEventName', msg);
    }
  }
  
  void setRealXY() {
    maxX = tMaxX;
    minX = tMinX;
    minY = tMinY;
    maxY = tMaxY;
  }
  
  void getMaxMinXY() {
    maxX = X1 > X2 ? X1 : X2;
    minX = X1 > X2 ? X2 : X1;
    maxY = Y1 > Y2 ? Y1 : Y2;
    minY = Y1 > Y2 ? Y2 : Y1;
  }
  
  //Update crap logic here, not scaling correctly
  //18-i is scaled at (1-0.05*i) for 18-i >5
  //1<=i<=5 has scale 0.05i might be scaled down by another 1/16th
  void scaleXY() {
    tMaxX = maxX / scale;
    tMinX = minX / scale;
    tMaxY = maxY / scale;
    tMinY = minY / scale;

    tX1 = X1 / scale;
    tY1 = Y1 / scale;
    tX2 = X2 / scale;
    tY2 = Y2 / scale;

    float diffX = (tMaxX - tMinX) - (maxX - minX);
    float diffY = (tMaxY - tMinY) - (maxY - minY);
    
    tMaxX = maxX + (diffX / 2);
    tMinX = minX - (diffX / 2);
    tMaxY = maxY + (diffY / 2);
    tMinY = minY - (diffY / 2);
  }
  
  //Please do not look at this method
  void getScale() {
    if(layer >= 18) {
      scale = 1;
      //do nothing
    } else if(layer > 5) {
      switch(layer) {
        case 17:
          scale = (0.05 * (18-layer)) / .05;
          break;
        case 16:
          scale = (0.05 * (18-layer)) / .1;
          break;
        case 15:
          scale = (0.05 * (18-layer)) / .15;
          break;
        case 14:
          scale = (0.05 * (18-layer)) / .2;
          break;
        case 13:
          scale = (0.05 * (18-layer)) / .25;
          break;
        case 12:
          scale = (0.05 * (18-layer)) / .3;
          break;
        case 11:
          scale = (0.05 * (18-layer)) / .37;
          break;
        case 10:
          scale = (0.05 * (18-layer)) / .445;
          break;
        case 9:
          scale = (0.05 * (18-layer)) / .53;
          break;
        case 8:
          scale = (0.05 * (18-layer)) / .625;
          break;
        case 7:
          scale = (0.05 * (18-layer)) / .73;
          break;
        case 6:
          scale = (0.05 * (18-layer)) / .86;
          break;
        default:
          break;
      }
    } else if(layer >= 1) {
      switch(layer) {
        case 5:
          scale = (0.05 * (18-layer)) / 2.6;
          break;
        case 4:
          scale = (0.05 * (18-layer)) / 3.5;
          break;
        case 3:
          scale = (0.05 * (18-layer)) / 5;
          break;
        case 2:
          scale = (0.05 * (18-layer)) / 8;
          break;
        case 1:
          scale = (0.05 * (18-layer)) / 17;
          break;
        default:
          break;
      }    
    } else {
      //Do nothing because layer 0 is dumb
    }
  }
  
  void OnMyCustomEventNameAck(string id, message@ msg) {
    if (msg.get_int('ack') == 1) {
      sendMessage = false;
    } else if (msg.get_int('req') == 1){
      sendMessage = true;
    }
  }
}

class SpawnHelper {
  [text]int speed, layer, sublayer, set, group, index, palette, direction, start;
  [text]bool exists;
  [hidden]bool isSprite;
  [text]float maxX, minX, maxY, minY, X1, X2, Y1, Y2, finalY;
  [text]float scaleX, scaleY;
  [text]string triggerID;
  [text]int frameSkip;
  [text]int wobbleAmplitude;
  [text]int wobbleSpeed;
  [text]bool rotateClockwiseOnly;
  [text]bool rotateCounterClockwiseOnly;
  [hidden]array<prop@> props;
  [hidden]string spriteName;
  [hidden]string spriteSet;
  [hidden]array<int32> propids;
  [hidden]float startingRotation;
  [hidden]float rotationSpeed;
  [hidden]float rotationClockwise;
  [hidden]float rotationCounterClockwise;
  [hidden]float sprx, spry, sprRotation;
  [hidden]bool runNTimes;
  [hidden]bool flipx;
  [hidden]bool flipy;
  [hidden]int numLaps;
  [hidden]int rotationDir;
  [hidden]int rotationPause;
  [hidden]int pauseTimer;
  SpawnHelper() {
    numLaps = 0;
    speed = 0;
    layer = 10;
    sublayer = 10;
    exists = false;
    runNTimes = false;
    flipx = false;
    flipy = false;
    isSprite = false;
    rotateClockwiseOnly = false;
    rotateCounterClockwiseOnly = false;
    spriteName = "spr1";
    spriteSet = "script";
    maxX = 0;
    minX = 0;
    maxY = 0;
    minY = 0;
    start = 1;
    set = 0;
    group = 0;
    index = 0;
    palette = 0;
    direction = 1;
    X1 = 0;
    Y1 = 0;
    X2 = 0;
    Y2 = 0;
    scaleX = 0;
    scaleY = 0;
    sprx = 0;
    spry = 0;
    sprRotation = 0;
    startingRotation = 0;
    rotationSpeed = 0;
    rotationClockwise = 0;
    rotationCounterClockwise = 0;
    frameSkip = 1;
    wobbleAmplitude = 0;
    wobbleSpeed = 0;
    rotationDir = 1;
    finalY = 0;
    rotationPause = 0;
    pauseTimer = 0;
  }

  void setStart(int dir) {
      direction = dir == 1 ? 1 : -1;
  }
}