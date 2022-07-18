#include "../jlib/math/PerlinNoise.as"
#include "../lib/math/Vec2.cpp"
const uint NO_TILE = 21;
class script {
  [slider, min:1, max:8] uint octaveCount = 1;
  [slider, min:1, max:20] float dotSize = 10;
  [slider, min:0.01, max:1.5] float scale = .2;
  [slider, min:1, max:10] int spacing;
  [slider, min:1, max:100] int spacingDots;
  [text] bool randomize = false;
  [text] bool generate = false;
  [text] bool debug = false;
  [text] bool drawGridOn = false;
  
  uint resolution = 10;
  uint cols, rows;

  uint debugCounter = 0;

  array<float> perlinNoise1d;
  array<float> perlinNoise2d;
  array<textfield@> tf(0);

  uint outputSize = 200;
  uint frame_count = 0;

  array<array<Vec2@>> lines;
  array<TileHelper@> tiles;
  array<array<float>> field (outputSize/resolution, array<float>(outputSize/resolution));
  PerlinNoise2 @p2;
  scene @g;

  script() {
    @g = get_scene();

    cols = outputSize/resolution;
    rows = outputSize/resolution;
    
    @p2 = PerlinNoise2(cols, rows, octaveCount);
    p2.seed();

    setupPerlinNoise2d();
    setupGrid();
  }

  
  void editor_var_changed(var_info@) {
    if(generate) {
      generateTiles();
    }
    if(debug) {
       resetDebugInfo();
       debugCounter++;
    }
  }


  void editor_draw(float subframe) {
    //drawPerlinNoise2();
    if(drawGridOn) {
      drawGrid();
    }

    drawLines();

    if(debug) {
      debugInfo();
    }
  }

  void editor_step() {
    stepPerlinNoise2();
    setupLines();

    frame_count++;
  }

  void debugInfo() {
    for(uint i = 0; i < tf.size(); i++) {
      tf[i].draw_world(20, 20, (tiles[i].x*48)+24,  (tiles[i].y*48)+24,.5 , .5, 0);
    }
  }
  
  void resetDebugInfo() {
     tf.removeRange(0, tf.size());
     for(uint i = 0; i < tiles.size(); i++) {
      textfield@ t = create_textfield();
      t.set_font("envy_bold", 20);
      t.text(tiles[i].type+"");
      t.colour(0xFF000000);
      tf.insertLast(t);
    }
  }

  void setupGrid() {
    srand(timestamp_now());
    for(uint i = 0; i < cols; i++) {
      for(uint j = 0; j < rows; j++) {
        float noise = perlinNoise2d[j * (cols) + i];
       // puts("noise["+(j * (cols) + i)+"] = "+perlinNoise2d[j * (cols) + i]);
        field[i][j] = round(noise);
      }
    }
  }

  void generateTiles() {
    puts("Generating! "+ tiles.size()+" tiles. Scale: "+scale+" octaves: "+octaveCount);
    debugCounter = 0;
    for(uint i = 0; i < tiles.size(); i++) {
      if(tiles[i].type != NO_TILE) {
        g.set_tile(tiles[i].x, tiles[i].y, 20, true, tiles[i].type, 2, 1, 1);
      }
    }
      // array<uint> vals(4);
      // for(uint i = 0; i < 15; i++) {
      //   switch(i) {
      //     case 0:
      //       vals[0] = NO_TILE; vals[1] = NO_TILE;
      //       vals[2] = NO_TILE; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 1:
      //       vals[0] = NO_TILE; vals[1] = NO_TILE;
      //       vals[2] = 17; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 2:
      //       vals[0] = NO_TILE; vals[1] = NO_TILE;
      //       vals[2] = NO_TILE; vals[3] = 20;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 3:
      //       vals[0] = NO_TILE; vals[1] = NO_TILE;
      //       vals[2] = 0; vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 4:
      //       vals[0] = NO_TILE; vals[1] = 19;
      //       vals[2] = NO_TILE; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 5:
      //       vals[0] = 20; vals[1] = 0;
      //       vals[2] = 0; vals[3] = 18;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 6:
      //       vals[0] = 0; vals[1] = NO_TILE;
      //       vals[2] = 0; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 7:
      //       vals[0] = 20; vals[1] = 0;
      //       vals[2] = 0; vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 8:
      //       vals[0] = 18;      vals[1] = NO_TILE;
      //       vals[2] = NO_TILE; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 9:
      //       vals[0] = NO_TILE; vals[1] = 0;
      //       vals[2] = NO_TILE; vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 10:
      //       vals[0] = 0;      vals[1] = 17;
      //       vals[2] = 19;     vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 11:
      //       vals[0] = 0; vals[1] = 17;
      //       vals[2] = 0; vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 12:
      //       vals[0] = 0;       vals[1] = 0;
      //       vals[2] = NO_TILE; vals[3] = NO_TILE;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 13:
      //       vals[0] = 0; vals[1] = 0;
      //       vals[2] = 0; vals[3] = 18;
      //       test_tile_drawing(i, vals);
      //       break;
      //     case 14:
      //       vals[0] = 0; vals[1] = 0;
      //       vals[2] = 19; vals[3] = 0;
      //       test_tile_drawing(i, vals);
      //       break;
      //   };
      // }
  }

  void test_tile_drawing(float i, array<uint> types) {
    draw_and_filter_empty_tiles((i+i *3), 0, 20, true, types[0], 2, 1, 1);
    draw_and_filter_empty_tiles((i+i *3)+1, 0, 20, true, types[1], 2, 1, 1);
    draw_and_filter_empty_tiles((i+i *3), 1, 20, true, types[2], 2, 1, 1);
    draw_and_filter_empty_tiles((i+i *3)+1, 1, 20, true, types[3], 2, 1, 1);
  }

  void draw_and_filter_empty_tiles(float x, float y, int layer, bool solid, uint type, uint index, uint set, uint pallet) {
    if(type != NO_TILE) {
      g.set_tile(x, y, layer, solid, type, index, set, pallet);
    }
  }

  void on_level_start() {
    g.set_tile(0, 0, 20, true,  18, 8, 1, 1);
    generateTiles();

  }

  void drawGrid() {
    for(uint i = 0; i < cols; i++) {
      for(uint j = 0; j < rows; j++) {
         uint color = 0xff;
         color = color << 8;
         color |= field[i][j] * 255;
         color = color << 8;
         color |= field[i][j] * 255;
         color = color << 8;
         color |= field[i][j] * 255;
        // void draw_rectangle_hud(uint layer, uint sub_layer, float x1, float y1,
        // float x2, float y2, float rotation, uint colour);
        float x = i*resolution; float y = j*resolution;
        g.draw_rectangle_world(19, 10, x-300, y-300, x+resolution-300, y-resolution-300, 0, color);
      }
    }

    //Potentially move to step
  }

  void setupLines() {
    lines.removeRange(0, lines.size());
    tiles.removeRange(0, tiles.size());
    for(uint i = 0; i < cols-1; i++) {
      for(uint j = 0; j < rows-1; j++) {
        float x = i * resolution;
        float y = j * resolution;
        Vec2 @a = Vec2(x + ((resolution * .5)), y);
        Vec2 @b = Vec2(x + resolution,        y + (resolution * .5));
        Vec2 @c = Vec2(x + (resolution * .5), y + resolution);
        Vec2 @d = Vec2(x,                     y + (resolution * .5));
        uint state = getState(field[i][j], field[i+1][j], field[i+1][j+1], field[i][j+1]);
        array<uint> vals(4);
        TileHelper @t;
        float tilex = i * 2;
        float tiley = j * 2;
        switch(state) {
          case 0:
            vals[0] = NO_TILE; vals[1] = NO_TILE;
            vals[2] = NO_TILE; vals[3] = NO_TILE;
            
            @t = TileHelper(tilex, tiley, vals[0]);
            tiles.insertLast(t);
            @t = TileHelper(tilex+1, tiley, vals[1]);
            tiles.insertLast(t);
            @t = TileHelper(tilex, tiley+1, vals[2]);
            tiles.insertLast(t);
            @t = TileHelper(tilex+1, tiley+1, vals[3]);
            tiles.insertLast(t);
            break;
          case 1:
            vals[0] = NO_TILE; vals[1] = NO_TILE;
            vals[2] = 17; vals[3] = NO_TILE;
            insertLine(c, d, vals, tilex, tiley);
            break;
          case 2:
            vals[0] = NO_TILE; vals[1] = NO_TILE;
            vals[2] = NO_TILE; vals[3] = 20;
            insertLine(b, c, vals, tilex, tiley);
            break;
          case 3:
            vals[0] = NO_TILE; vals[1] = NO_TILE;
            vals[2] = 0; vals[3] = 0;
            insertLine(b, d, vals, tilex, tiley);
            break;
          case 4:
            vals[0] = NO_TILE; vals[1] = 19;
            vals[2] = NO_TILE; vals[3] = NO_TILE;
            insertLine(a, b, vals, tilex, tiley);
            break;
          case 5:
            vals[0] = 20; vals[1] = 0;
            vals[2] = 0; vals[3] = 18;
            insertLine(a, d, vals, tilex, tiley);
            insertLine(b, c);
            break;
          case 6:
            vals[0] = NO_TILE; vals[1] = 0;
            vals[2] = NO_TILE; vals[3] = 0;
            insertLine(a, c, vals, tilex, tiley);
            break;
          case 7:
            vals[0] = 20; vals[1] = 0;
            vals[2] = 0; vals[3] = 0;
            insertLine(a, d, vals, tilex, tiley);
            break;
          case 8:
            vals[0] = 18;      vals[1] = NO_TILE;
            vals[2] = NO_TILE; vals[3] = NO_TILE;
            insertLine(a, d, vals, tilex, tiley);
            break;
          case 9:
            vals[0] = 0; vals[1] = NO_TILE;
            vals[2] = 0; vals[3] = NO_TILE;
            insertLine(a, c, vals, tilex, tiley);
            break;
          case 10:
            vals[0] = 0;      vals[1] = 17;
            vals[2] = 19;     vals[3] = 0;
            insertLine(a, b, vals, tilex, tiley);
            insertLine(c, d);
            break;
          case 11:
            vals[0] = 0; vals[1] = 17;
            vals[2] = 0; vals[3] = 0;
            insertLine(a, b, vals, tilex, tiley);
            break;
          case 12:
            vals[0] = 0;       vals[1] = 0;
            vals[2] = NO_TILE; vals[3] = NO_TILE;
            insertLine(b, d, vals, tilex, tiley);
            break;
          case 13:
            vals[0] = 0; vals[1] = 0;
            vals[2] = 0; vals[3] = 18;
            insertLine(b, c, vals, tilex, tiley);
            break;
          case 14:
            vals[0] = 0; vals[1] = 0;
            vals[2] = 19; vals[3] = 0;
            insertLine(c, d, vals, tilex, tiley);
            break;
          case 15:
            vals[0] = 0; vals[1] = 0;
            vals[2] = 0; vals[3] = 0;
            
            @t = TileHelper(tilex, tiley, vals[0]);
            tiles.insertLast(t);
            @t = TileHelper(tilex+1, tiley, vals[1]);
            tiles.insertLast(t);
            @t = TileHelper(tilex, tiley+1, vals[2]);
            tiles.insertLast(t);
            @t = TileHelper(tilex+1, tiley+1, vals[3]);
            tiles.insertLast(t);
            break;
        };
      }
    }
  }

  void insertLine(Vec2@ a, Vec2@ b) {
    array<Vec2@> temp = {a,b};
    lines.insertLast(temp);
  }

  void insertLine(Vec2@ a, Vec2@ b, array<uint> tileVals, float tilex, float tiley) {
    array<Vec2@> temp = {a,b};
    lines.insertLast(temp);

    TileHelper @t1 = TileHelper(tilex,   tiley,   tileVals[0]);
    TileHelper @t2 = TileHelper(tilex+1, tiley,   tileVals[1]);
    TileHelper @t3 = TileHelper(tilex,   tiley+1, tileVals[2]);
    TileHelper @t4 = TileHelper(tilex+1, tiley+1, tileVals[3]);

    tiles.insertLast(t1);
    tiles.insertLast(t2);
    tiles.insertLast(t3);
    tiles.insertLast(t4);
    
  }

  int getState(uint a, uint b, uint c, uint d) {
    return a * 8 + b * 4 + c * 2 + d * 1;
  }

  void drawVecLine(Vec2 @a, Vec2 @b, uint color = 0xFFFFFFFF) {
    //void draw_line_hud(uint layer, uint sub_layer, float x1, float y1, float x2, float y2, float width, uint colour)
    g.draw_line_world(19, 19, a.x, a.y, b.x, b.y, 1, color);
  } 

  void drawLines() {
    for(uint i = 0; i < lines.size(); i++) {
      g.draw_line_world(19, 19, lines[i][0].x-300, lines[i][0].y-300, lines[i][1].x-300, lines[i][1].y-300, 1, 0xffffffff);
    }
  }

  void drawPerlinNoise2() {
    if(perlinNoise2d.size() > 0) {
      for (uint x = 0; x < outputSize; x++) {
        for (uint y = 0; y < outputSize; y++) {
            
            float noise = perlinNoise2d[y * outputSize + x];

            //Draw on top of rectangles sublayer 20
            g.draw_rectangle_hud(19,20,x*spacing, y*spacing, x*spacing+3, y*spacing+9, noise * 360, 0xffffffff);
        }
      }
    }
  }

  void stepPerlinNoise2() {
    if(@p2 == null || randomize) {
      setupPerlinNoise2d();
    }

    p2.setOctaves(octaveCount);
    p2.setScale(scale);
    p2.setOutSize(outputSize/resolution, outputSize/resolution);
    perlinNoise2d = p2.generateNoise2d();
    setupGrid();
  }

  void setupPerlinNoise2d() {
    p2.seed();
    p2.setOctaves(octaveCount);
    p2.setScale(scale);
    p2.setOutSize(outputSize/resolution, outputSize/resolution);
    perlinNoise2d = p2.generateNoise2d();
    setupGrid();
  }
}

class TileHelper {
  float x;
  float y;
  uint type;
  TileHelper(float xin, float yin, float typein) {
    x = xin;
    y = yin;
    type = typein;
  }
}