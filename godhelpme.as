#include "jlib/math/Matrix.as"
#include "jlib/math/Vec3.as"

class script
{
  scene@ g;
  int frame = 0;
  Matrix@ a;
  Matrix@ b;
  script() {
    @g = get_scene();
  }
  
  void on_level_start() {
    array<array<float>> aarr = {{1.0, 0.0, 0.0},
                                {0.0, 1.0, 0.0}};
                                
    array<array<float>> barr = {{100.0},
                                {75.0},
                                {50.0}};
    @a = Matrix(aarr);
    @b = Matrix(barr);
  }

  void step(int) {
    frame++;
    if(frame % 60 == 0) {
      Matrix@ test = vecToMatrix(Vec3());
      Matrix@ result = a.multiply(b);
      Vec3@ v = matrixToVec3(result);

      v.print();
    }
  }
}