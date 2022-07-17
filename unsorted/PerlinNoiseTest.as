#include "../jlib/math/PerlinNoise.as"
class script {
  [slider, min:1, max:8] uint octaveCount;
  [slider, min:1, max:20] float dotSize;
  [slider, min:0.02, max:1.5] float scale;
  [slider, min:1, max:10] int spacing;
  [option, 0:one, 1:two]int nMode;
  [text] bool randomize = false;
  array<float> perlinNoise1d;
  array<float> perlinNoise2d;
  [slider, min:1, max:100] uint outputSize;
  uint frame_count = 0;
  PerlinNoise @p;
  PerlinNoise2 @p2;
  scene @g;

  script() {
    @g = get_scene();
    @p = PerlinNoise(outputSize, octaveCount);
    p.seed();

    @p2 = PerlinNoise2(outputSize, outputSize, octaveCount);
    p2.seed();
  }

  
  void editor_draw(float subframe) {
    nMode == 0 ? drawPerlinNoise() : drawPerlinNoise2();
  }

  void editor_step() {
    nMode == 0 ? stepPerlinNoise() : stepPerlinNoise2();

    frame_count++;
  }

  void stepPerlinNoise() {
    if(@p == null || randomize) {
      @p = PerlinNoise(outputSize, octaveCount, scale);
      p.seed();
    }
    p.setOctaves(octaveCount);
    p.setScale(scale);
    p.setMode(nMode);
    perlinNoise1d = p.PerlinNoise1D();
  }

  void drawPerlinNoise() {
    if(perlinNoise1d.size() > 0) {
      for (uint x = 0; x < outputSize-1; x++) {
        int y = -(perlinNoise1d[x] * float(SCREEN_HEIGHT / 2.0f)) + 0;
        if(x+1 < perlinNoise1d.size()) {
          int y2 = -(perlinNoise1d[x+1] * float(SCREEN_HEIGHT / 2.0f)) + 0;
          //void draw_line_hud(uint layer, uint sub_layer, float x1, float y1, float x2, float y2, float width, uint colour)
          g.draw_line_hud(19,19,x, y, x+1, y2, 3, 0xffffffff);
        }
      }
    }
  }

  void drawPerlinNoise2() {
    if(perlinNoise2d.size() > 0) {
      for (uint x = 0; x < outputSize; x++) {
        for (uint y = 0; y < outputSize; y++) {
            
            float noise = perlinNoise2d[y * outputSize + x];

            //void draw_line_hud(uint layer, uint sub_layer, float x1, float y1, float x2, float y2, float width, uint colour)
            g.draw_rectangle_hud(19,19,x*spacing, y*spacing, x*spacing+3, y*spacing+9, noise * 360, 0xffffffff);
        }
      }
    }
  }

  void stepPerlinNoise2() {
    if(@p2 == null || randomize) {
      p2.seed();
    }
    p2.setOctaves(octaveCount);
    p2.setScale(scale);
    p2.setOutSize(outputSize, outputSize);
    perlinNoise2d = p2.PerlinNoise2D();
    
  }
}