#include "../lib/math/Line.cpp";
#include "../lib/props/common.cpp"
#include "../lib/drawing/Sprite.cpp"
const int BASE_SPAWN_RATE = 8000;
const uint WHITE = 0xFFFFFFFF; 
const uint GREEN = 0xFF00FF00; 
const uint WHITE_TRANSPARENT = 0x4AFFFFFF; 
const uint GREEN_TRANSPARENT = 0x4A00FF00; 
const uint FRAME_SKIP = 2;
//18-i is scaled at (1-0.05*i) for 18-i >5
//1<=i<=5 has scale 0.05i might be scaled down by another 1/16th

class script : callback_base {
  [text]array<SpawnHelper@> spawnArr;
  scene@ g;
  int frame_cp;
  int frameCount;
  [hidden]array<SpawnHelper@> savedClouds;
  bool exists = false;
  array<int> triggerIDs;
  script() {
    frameCount = 0;
    @g = get_scene();
    srand(timestamp_now());
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    //override_stream_sizes(100, 8);
  }

  void on_level_start() {}

  void step(int entities) {  
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      
      if (!sh.exists) {
        sh.exists = true;
        prop @p = makeProp(@sh);
        g.add_prop(@p);
        sh.props.insertLast(@p);
        sh.propids.insertLast(p.id());
      }
      
      Line propPath(sh.X1, sh.Y1, sh.X2, sh.Y2);
   
      for(uint i = 0; i < sh.props.length(); i++) {
        prop @pr = sh.props[i];
        if(@pr == null) { //If somehow we lost the handle, remove the prop from our array
          sh.props.removeAt(i);
          sh.propids.removeAt(i);
        } else if(frameCount % FRAME_SKIP == 0 && continueLaps(sh)) { // Otherwise if this isnt a skipped frame AND we havent completed our lap count, move the prop
            if(sh.props[i].x() >= sh.maxX || sh.props[i].x() <= sh.minX) {
              flipDirection(sh, pr, sh.props[i].x() >= sh.maxX ? -1 : 1);
            } else {
                pr.x(pr.x() + (sh.speed * sh.direction));
                pr.y(propPath.getY(pr.x()));
            }
        }
      }
    }
    frameCount++;
  }
  
  bool continueLaps(SpawnHelper@ sh) {
    return !sh.runNTimes || (sh.runNTimes && sh.numLaps >= 0);
  }

  void flipDirection(SpawnHelper@ sh, prop@ pr, int dir) {
    Line propPath(sh.X1, sh.Y1, sh.X2, sh.Y2);

    // Change direction of movement and start moving other way
    sh.direction = dir;

    // Flip the prop if needed for X/Y
    pr.scale_x(sh.flipx ? -1 * pr.scale_x() : pr.scale_x());
    pr.scale_y(sh.flipy ? -1 * pr.scale_y() : pr.scale_y());
    pr.x(pr.x() + (sh.speed * sh.direction));
    pr.y(propPath.getY(pr.x()));

    // Decrement lap count
    sh.numLaps--;
  }

  void checkpoint_save() { }

  void checkpoint_load() {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      for(uint i = 0; i < sh.props.length(); i++) {
        if(@sh.props[i] != null) {
            @sh.props[i] = prop_by_id(sh.props[i].id());
        }
      }
    }
  }
  
  void editor_step() {
    for(uint j = 0; j < spawnArr.length(); j++) {
       SpawnHelper@ sh = spawnArr[j];
       for(uint i = 0; i < sh.props.length(); i++) {
        if(@sh.props[i] != null && @prop_by_id(sh.props[i].id()) != null) {
          g.remove_prop(prop_by_id(sh.props[i].id()));
          sh.props.removeAt(i);
        }
      }
    }
  }
 
  prop@ makeProp(SpawnHelper@ sh) {
    prop@ pr = create_prop();
    pr.layer(sh.layer);
    pr.sub_layer(sh.sublayer);
    pr.prop_set(sh.set);
    pr.prop_group(sh.group);
    pr.prop_index(sh.index);
    pr.palette(sh.palette);
    pr.scale_x(sh.scaleX);
    pr.scale_y(sh.scaleY);
    pr.rotation(sh.rotation);
    //puts('X1: '+sh.X1+"Y11: "+sh.Y1);
    pr.x(sh.start == 1 ? sh.X1 : sh.X2);
    pr.y(sh.Y1);
    return @pr;
  }

  void OnMyCustomEventName(string id, message@ msg) {

    if(msg.get_string('triggerType') == 'cloudMove') {
      SpawnHelper@ tmpSH = SpawnHelper();
      if(@tmpSH == null) {
        
      }
      
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
      tmpSH.set = msg.get_int('set');
      tmpSH.group = msg.get_int('group');
      tmpSH.index = msg.get_int('index');
      tmpSH.palette = msg.get_int('palette');
      tmpSH.start = msg.get_int('start');
      tmpSH.numLaps = msg.get_int('numLaps');
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
      tmpSH.rotation = msg.get_float('rotation');
      tmpSH.triggerID = msg.get_string('triggerID');
      spawnArr.insertLast(tmpSH);
    }
  }
}



class RailTrigger : trigger_base, callback_base { 
  [hidden]string name;
  [text]int prop_set;
  [text]int prop_group;
  [text]int prop_index;
  [text]int prop_palette;
  [text]int layer;
  [text]int sublayer;
  [text]int speed;
  [hidden] float Y1, Y2;
  [position,mode:world,layer:18,y:Y1] float X1;
  [position,mode:world,layer:18,y:Y2] float X2;
  [text]bool showLines;
  [text]bool flipx;
  [text]bool flipy;
  [text]bool runNTimes;
  [text]int numLaps;
  [option,0:Right,1:Left] int start;
  [hidden] float Y1Backup;
  [hidden] bool sendMessage;
  [hidden] float maxX, minX, maxY, minY;
  [text] float scalePropX;
  [text] float scalePropY;
  [hidden] float scale;
  [angle] float rotation;
  [hidden] float tMaxX, tMaxY, tMinX, tMinY;
  [hidden] float tX1, tY1, tX2, tY2;
  [hidden] float realX1, realY1, realX2, realY2;
  [hidden] string sprSet, sprName;
  scene@ g;
  scripttrigger@ self;
  Sprite spr1, spr2;

  RailTrigger() {
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
  }

  void init(script@ s, scripttrigger@ self ) {
    @this.self = @self;
    name = "railTrigger" + self.as_entity().id();
    Y1 = Y1Backup;
    getMaxMinXY();
    getScale();
    scaleXY();
    //void sprite_from_prop(uint prop_set, uint prop_group, uint prop_index, string &out sprite_set, string &out sprite_name)
    sprite_from_prop(prop_set, prop_group, prop_index, sprSet, sprName);
	  spr1.set(sprSet, sprName);
    spr2.set(sprSet, sprName);
    spr1.real_position(X1, Y1, rotation, realX1, realY1, scalePropX, scalePropY);
    spr2.real_position(X2, Y2, rotation, realX2, realY2, scalePropX, scalePropY);
    //puts('realX1: '+realX1+"realY1: "+realY1);
  }

  void editor_draw(float sub_frame) {
    if(showLines) {
        g.draw_line_world(layer, 10, tX1, tY1, tX2, tY2, 5, this.self.editor_selected() ? WHITE : WHITE_TRANSPARENT);
        Y1Backup = Y1;
        g.draw_line_world(18, 10, X1, Y1, X2, Y2, 5, this.self.editor_selected() ? GREEN : GREEN_TRANSPARENT);
        drawProps();
    }
  }
  void drawProps() {
    spr1.draw(layer, sublayer, 0, prop_palette, tX1, tY1, rotation, scalePropX, scalePropY, WHITE);
    spr2.draw(layer, sublayer, 0, prop_palette, tX2, tY2, rotation, scalePropX, scalePropY, WHITE);
  }

  void editor_step() {
    getMaxMinXY();
    getScale();
    scaleXY();
    //void sprite_from_prop(uint prop_set, uint prop_group, uint prop_index, string &out sprite_set, string &out sprite_name)
    sprite_from_prop(prop_set, prop_group, prop_index, sprSet, sprName);
	  spr1.set(sprSet, sprName);
    spr2.set(sprSet, sprName);
    spr1.real_position(X1, Y1, rotation, realX1, realY1, scalePropX, scalePropY);
    spr2.real_position(X2, Y2, rotation, realX2, realY2, scalePropX, scalePropY);
    //puts('realX1: '+realX1+"realY1: "+realY1);
  }

  void step() {
    if(sendMessage) {
      message@ msg = create_message();
      msg.set_string('triggerID', name);
      msg.set_string('triggerType', 'cloudMove');
      msg.set_int('speed', speed);
      msg.set_int('layer', layer);
      msg.set_int('sublayer', sublayer);
      msg.set_int('set', prop_set);
      msg.set_int('group', prop_group);
      msg.set_int('index', prop_index);
      msg.set_int('palette', prop_palette);
      msg.set_int('start', start);
      msg.set_int('runNTimes', runNTimes ? 1:0);
      msg.set_int('numLaps', numLaps);
      msg.set_int('flipx', flipx ? 1:0);
      msg.set_int('flipy', flipy ? 1:0);
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
      msg.set_float('rotation', rotation);
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
  //[option,1:Cloud1,2:Cloud2,3:Cloud3,4:Cloud4,5:Cloud5,6:Cloud6]
  [text]float maxX, minX, maxY, minY, X1, X2, Y1, Y2;
  [text]float scaleX, scaleY;
  [text]string triggerID;
  [hidden]array<prop@> props;
  [hidden]array<int32> propids;
  [hidden]float rotation;
  [hidden]bool runNTimes;
  [hidden]bool flipx;
  [hidden]bool flipy;
  [hidden]int numLaps;
  SpawnHelper() {
    numLaps = 0;
    speed = 0;
    layer = 10;
    sublayer = 10;
    exists = false;
    runNTimes = false;
    flipx = false;
    flipy = false;
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
    rotation = 0;
  }

  void setStart(int dir) {
      direction = dir == 1 ? 1 : -1;
  }
}