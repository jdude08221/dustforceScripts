const int BASE_SPAWN_RATE = 8000;

//18-i is scaled at (1-0.05*i) for 18-i >5
//1<=i<=5 has scale 0.05i might be scaled down by another 1/16th

class script : callback_base {
  [text]array<SpawnHelper@> spawnArr;
  scene@ g;
  int frame_cp;
  

  array<int> triggerIDs;
  
  script() {
    @g = get_scene();
    srand(timestamp_now());
    add_broadcast_receiver('OnMyCustomEventName', this, 'OnMyCustomEventName');
    //override_stream_sizes(100, 8);
  }
  
  void step(int entities) {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      
      //Random number to determine if we should spawn a cloud
      uint32 r1 = rand();
        
      if(sh.spawnCloudsOnStart) {
        sh.spawnCloudsOnStart = false;
        makeFirstProps();
      } else if (sh.density != 0 && ((r1 % (BASE_SPAWN_RATE / (sh.speed > 0 ? sh.speed : 1))) < sh.density)) {
        prop @p = makeCloud(sh.minX, @sh);
        g.add_prop(@p);
        sh.props.insertLast(@p);
        sh.propids.insertLast(p.id());
      }
      
      for(uint i = 0; i < sh.props.length(); i++) {
        prop @pr = sh.props[i];
        
        if(@pr == null) {
          sh.props.removeAt(i);
          sh.propids.removeAt(i);
        } else if(sh.props[i].x() >= sh.maxX) {
          g.remove_prop(@pr);
          sh.props.removeAt(i);
          sh.propids.removeAt(i);
          puts("removed ids:" + sh.propids.length() + " props:" + sh.props.length());
        } else { 
          pr.x(pr.x() + sh.speed);
        }
      }
    } 
  }

  void makeFirstProps() {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      
      for(float x = sh.maxX; x > sh.minX; x -= sh.speed) {
        uint32 r1 = rand();
        if (x == sh.maxX || (sh.density != 0 && ((r1 % (BASE_SPAWN_RATE / sh.speed)) < sh.density))) {
          prop @p = makeCloud(x, @sh);
          g.add_prop(@p);
          sh.props.insertLast(@p);
          sh.propids.insertLast(p.id());
        } 
      }
    }
  }
  
  void checkpoint_save() {
  }

  void checkpoint_load() {
    for(uint j = 0; j < spawnArr.length(); j++) {
      SpawnHelper@ sh = spawnArr[j];
      puts("load ids:" + sh.propids.length() + " props:" + sh.props.length());
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
 
  prop@ makeCloud(float inX, SpawnHelper@ sh) {
    //puts("chosenCloud:" + sh.chosenCloud + " randomWhiteClouds:" + sh.randomWhiteClouds);
    updateChosenCloud(sh);
    //puts("Spawning cloud " + sh.chosenCloud);
    float r2 = rand() % 100;
    r2 /= 100;
    prop@ pr = create_prop();

    pr.layer(sh.layer);
    pr.sub_layer(sh.sublayer);
    //Assumption is that clouds are being used only.
    //Logic would have to be updated for non-cloud props
    pr.prop_set(sh.chosenCloud <= 3 ? 1 : 2);
    pr.prop_group(22);
    pr.prop_index(sh.chosenCloud <= 3 ? sh.chosenCloud : sh.chosenCloud - 3);
    //Flip clouds to face correct direction in wind
    pr.scale_x(sh.chosenCloud == 2 || sh.chosenCloud == 5 ? -1 : 1);
    pr.palette(1);
    pr.x(inX);

    //Set the y value to be between min and max y.  
    //To avoid divide by 0, run a check.
    float testY = floor(r2 * (sh.maxY - sh.minY + 1) + sh.minY);
    
    pr.y(testY);
    return @pr;
  }
  

  void updateChosenCloud(SpawnHelper@ sh) {
    uint32 r3 = rand();
    if(sh.randomWhiteClouds) {
      sh.chosenCloud = (r3 % 3) + 4;
    } else if(sh.randomDarkClouds) {
      sh.chosenCloud = (r3 % 3) + 1;
    } else if(sh.randomMixedClouds) {
      sh.chosenCloud = (r3 % 6) + 1;
    }
  } 

  void OnMyCustomEventName(string id, message@ msg) {
    if(msg.get_string('triggerType') == 'cloudMove') {
      SpawnHelper@ tmpSH = SpawnHelper();
      if(@tmpSH == null) {
        puts('tmpsh');
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
      tmpSH.density = msg.get_int('density');
      tmpSH.spawnCloudsOnStart = (msg.get_int('spawnCloudsOnStart') == 1);
      tmpSH.randomWhiteClouds = (msg.get_int('randomWhiteClouds') == 1);
      tmpSH.randomDarkClouds = (msg.get_int('randomDarkClouds') == 1);
      tmpSH.randomMixedClouds = (msg.get_int('randomMixedClouds') == 1);
      tmpSH.chosenCloud = msg.get_int('chosenCloud');
      tmpSH.maxX = msg.get_float('maxX');
      tmpSH.minX = msg.get_float('minX');
      tmpSH.maxY = msg.get_float('maxY');
      tmpSH.minY = msg.get_float('minY');
      tmpSH.scale = msg.get_float('scale');
      tmpSH.triggerID = msg.get_string('triggerID');
      puts("ID: " + tmpSH.triggerID);
      spawnArr.insertLast(tmpSH);
    }
  }
}



class CloudTrigger : trigger_base, callback_base { 
  [hidden]string name;
  [text]int speed;
  [text]int layer;
  [text]int sublayer;
  [text]int density;
  [text]bool spawnCloudsOnStart;
  [text]bool showBoxes;
  [option,1:Cloud1,2:Cloud2,3:Cloud3,4:Cloud4,5:Cloud5,6:Cloud6,7:RandomWhite,8:RandomDark,9:RandomMixed]int chosenCloud;
  [hidden]int position;
  [hidden] float Y1Backup;
  [hidden] float Y1, Y2;
  [position,mode:world,layer:18,y:Y1] float X1;
  [position,mode:world,layer:18,y:Y2] float X2;
  [hidden] bool sendMessage;
  [hidden] float maxX, minX, maxY, minY;
  [hidden] float scale;
  [hidden] float tMaxX, tMaxY, tMinX, tMinY;
  
  scene@ g;
  scripttrigger@ self;
  
  CloudTrigger() {
    @g = get_scene();
    puts("CloudTrigger()");
    position = speed = density = 0;
    layer = sublayer = 15;
    spawnCloudsOnStart = showBoxes = false;
    X1 = Y1 = X2 = Y2 = 0;
    Y1Backup = 0;
    chosenCloud = 1;
    scale = 1;
    sendMessage = true;
    name = "cloudTrigger";
    add_broadcast_receiver('OnMyCustomEventNameAck', this, 'OnMyCustomEventNameAck');
  }
  
  void init(script@ s, scripttrigger@ self ) {
    @this.self = @self;
    name = "cloudTrigger" + self.as_entity().id();
    Y1 = Y1Backup;
    getMaxMinXY();
    getScale();
    scaleXY();
    setRealXY();
  }

  void editor_draw(float sub_frame) {
    if(showBoxes) {
      //puts("X1 " + X1 + " Y1 " + Y1 + " X2 " + X2 + " Y2 " + Y2);
      //puts("tMaxX " + tMaxX + " tMaxY " + tMaxY + " tMinX " + tMinX + " tMinY " + tMinY);
      g.draw_rectangle_world(layer, 10, tMaxX, tMaxY, tMinX, tMinY, 0, 0x4AFFFFFF);
      Y1Backup = Y1;
      g.draw_rectangle_world(18, 10, X1, Y1, X2, Y2, 0, 0x4A00FF00);
    }
  }
  
  void editor_step() {
    getMaxMinXY();
    getScale();
    scaleXY();
  }
  
  void step() {
    if(sendMessage) {
      //puts("X1 " + X1 + " Y1 " + Y1 + " X2 " + X2 + " Y2 " + Y2);
      message@ msg = create_message();
      msg.set_string('triggerID', name);
      msg.set_string('triggerType', 'cloudMove');
      msg.set_int('speed', speed);
      msg.set_int('layer', layer);
      msg.set_int('sublayer', sublayer);
      msg.set_int('density', density);
      msg.set_int('chosenCloud', chosenCloud);
      msg.set_float('maxX', maxX);
      msg.set_float('minX', minX);
      msg.set_float('maxY', maxY);
      msg.set_float('minY', minY);
      msg.set_float('scale', scale);
      
      //Bools 
      msg.set_int('spawnCloudsOnStart', spawnCloudsOnStart ? 1 : 0);
      msg.set_int('randomWhiteClouds', chosenCloud == 7 ? 1 : 0);
      msg.set_int('randomDarkClouds', chosenCloud == 8 ? 1 : 0);
      msg.set_int('randomMixedClouds', chosenCloud == 9 ? 1 : 0);
      
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
  [text]int speed, layer, sublayer, density;
  [text]bool spawnCloudsOnStart, randomWhiteClouds, randomDarkClouds, randomMixedClouds;
  //[option,1:Cloud1,2:Cloud2,3:Cloud3,4:Cloud4,5:Cloud5,6:Cloud6]
  [text]int chosenCloud;
  [text]float maxX, minX, maxY, minY;
  [text]float scale;
  [text]string triggerID;
  [hidden]array<prop@> props;
  [hidden]array<int32> propids;
  SpawnHelper() {
    speed = 0;
    layer = 10;
    sublayer = 10;
    density = 0;
    spawnCloudsOnStart = false;
    randomWhiteClouds = false;
    randomDarkClouds = false;
    randomMixedClouds = false;
    chosenCloud = 0;
    maxX = 0;
    minX = 0;
    maxY = 0;
    minY = 0;
    scale = 0;
  }
}