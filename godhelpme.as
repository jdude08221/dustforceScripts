
//https://en.wikipedia.org/wiki/Rotation_matrix
//https://www.youtube.com/watch?v=p4Iz0XJY-Qk
#include "jlib/math/Matrix.as"
#include "jlib/math/Vec3.as"
#include "jlib/const/ColorConsts.as"
#include "lib/math/math.cpp"

class script
{
  [position,mode:world,layer:18,y:Y1] float X1;
  [hidden] float Y1;
  float rotSpeed = 2;
  float cube_scale = 5;
  float cube_rotation = 5;
  float distance = 10;
  [entity] int apple;
  entity@ appleE;
  float XT1 = -.5;
  float YT1 = -.5;
  float drawFrame = 0;
  float offsetX;
  float offsetY;

  float edgeLength = 1;
  scene@ g;
  int frame = 0;
  float angle = 0;
  array<Vec3@> points(8);
  array<Vec3@> drawPoints(8);

  script() {
    @g = get_scene();
    setupPoints();
    X1 = 0 - edgeLength/2; 
    Y1 = 0 + edgeLength/2 ;
  }
  
  void setupPoints() {
    float halfEdge = edgeLength / 2;
    @points[0] = Vec3(XT1, YT1, -halfEdge);
    @points[1] = Vec3(XT1 + edgeLength, YT1, -halfEdge);
    @points[2] = Vec3(XT1, YT1 + edgeLength, -halfEdge);
    @points[3] = Vec3(XT1 + edgeLength, YT1 + edgeLength, -halfEdge);

    @points[4] = Vec3(XT1, YT1, halfEdge);
    @points[5] = Vec3(XT1 + edgeLength, YT1, halfEdge);
    @points[6] = Vec3(XT1, YT1 + edgeLength, halfEdge);
    @points[7] = Vec3(XT1 + edgeLength, YT1 + edgeLength, halfEdge);

    for(uint i = 0; i < points.size(); i ++) {
      @drawPoints[i] = @points[i];
    }
  }

  
  void on_level_start() {
    setupPoints();
    offsetX = XT1 + X1;
    offsetY = YT1 + Y1;
  }

  Matrix@ rotationX() {
    array<array<float>> rotX = {
    { 1, 0, 0},
    { 0, cos(angle), -sin(angle)},
    { 0, sin(angle), cos(angle)}};
                                
    return Matrix(rotX);
  }

  Matrix@ rotationY() {
    array<array<float>> rotY = {
    { cos(cube_rotation), 0, sin(cube_rotation)},
    { 0, 1, 0},
    { -sin(cube_rotation), 0, cos(cube_rotation)}};
                                
    return Matrix(rotY);
  }

  Matrix@ rotationZ() {
   array<array<float>> rotZ = { 
    { cos(45 * DEG2RAD), -sin(45 * DEG2RAD), 0},
    { sin(45 * DEG2RAD), cos(45 * DEG2RAD), 0},
    { 0, 0, 1}};
                                
    return Matrix(rotZ);
  }

  Matrix@ projection(float rotatedZ) {
    float z = 1.0/(distance - rotatedZ);
      array<array<float>> arrProj = {{1/z, 0.0, 0.0},
                                      {0.0, 1/z, 0.0}};
                              
    return Matrix(arrProj);
  }

  void drawQuads() {
      //front
      // g.draw_quad_world(20, 19, false,
      // drawPoints[0].x, drawPoints[0].y, drawPoints[2].x, drawPoints[2].y,
      // drawPoints[3].x, drawPoints[3].y, drawPoints[1].x, drawPoints[1].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);

      // //left
      // g.draw_quad_world(20, 19, false,
      // drawPoints[4].x, drawPoints[4].y, drawPoints[6].x, drawPoints[6].y,
      // drawPoints[2].x, drawPoints[2].y, drawPoints[0].x, drawPoints[0].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);
      
      // //right
      // g.draw_quad_world(20, 19, false,
      // drawPoints[1].x, drawPoints[1].y, drawPoints[3].x, drawPoints[3].y,
      // drawPoints[7].x, drawPoints[7].y, drawPoints[5].x, drawPoints[5].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);

      // //bottom
      // g.draw_quad_world(20, 19, false,
      // drawPoints[2].x, drawPoints[2].y, drawPoints[3].x, drawPoints[3].y,
      // drawPoints[7].x, drawPoints[7].y, drawPoints[6].x, drawPoints[6].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);

      // //top
      // g.draw_quad_world(20, 19, false,
      // drawPoints[4].x, drawPoints[4].y, drawPoints[5].x, drawPoints[5].y,
      // drawPoints[1].x, drawPoints[1].y, drawPoints[0].x, drawPoints[0].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);

      // //back
      // g.draw_quad_world(20, 19, false,
      // drawPoints[5].x, drawPoints[5].y, drawPoints[4].x, drawPoints[4].y,
      // drawPoints[6].x, drawPoints[6].y, drawPoints[7].x, drawPoints[7].y,
      // PURPLE, PURPLE, PURPLE, PURPLE);
  }

  void drawLines() {
    //Front Face
    g.draw_line_world(18, 8, drawPoints[0].x + offsetX, drawPoints[0].y + offsetY,
      drawPoints[1].x + offsetX, drawPoints[1].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[1].x + offsetX, drawPoints[1].y + offsetY,
      drawPoints[3].x + offsetX, drawPoints[3].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[3].x + offsetX, drawPoints[3].y + offsetY,
      drawPoints[2].x + offsetX, drawPoints[2].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[2].x + offsetX, drawPoints[2].y + offsetY,
      drawPoints[0].x + offsetX, drawPoints[0].y + offsetY, 5, 0xFFFFFFFF);

    //back face
    g.draw_line_world(18, 8, drawPoints[4].x + offsetX, drawPoints[4].y + offsetY,
      drawPoints[5].x + offsetX, drawPoints[5].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[5].x + offsetX, drawPoints[5].y + offsetY,
      drawPoints[7].x + offsetX, drawPoints[7].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[7].x + offsetX, drawPoints[7].y + offsetY,
      drawPoints[6].x + offsetX, drawPoints[6].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[6].x + offsetX, drawPoints[6].y + offsetY,
      drawPoints[4].x + offsetX, drawPoints[4].y + offsetY, 5, 0xFFFFFFFF);

      //Connecting Faces
    g.draw_line_world(18, 8, drawPoints[4].x + offsetX, drawPoints[4].y + offsetY,
      drawPoints[0].x + offsetX, drawPoints[0].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[5].x + offsetX, drawPoints[5].y + offsetY,
      drawPoints[1].x + offsetX, drawPoints[1].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[7].x + offsetX, drawPoints[7].y + offsetY,
      drawPoints[3].x + offsetX, drawPoints[3].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, drawPoints[6].x + offsetX, drawPoints[6].y + offsetY,
      drawPoints[2].x + offsetX, drawPoints[2].y + offsetY, 5, 0xFFFFFFFF);
  }

  void step(int) {
    if(@entity_by_id(apple) != null) {
      @appleE = entity_by_id(apple);
    } 
    
    if(@appleE != null) {
      offsetX = appleE.x() + XT1;
      offsetY = appleE.y() + YT1;
    }

    frame++;
    cube_rotation = angle;
    for(uint i = 0; i < drawPoints.size(); i++) {
      @drawPoints[i] = rotationY().multiply(points[i]);
      @drawPoints[i] = rotationX().multiply(drawPoints[i]);
      @drawPoints[i] = rotationZ().multiply(drawPoints[i]);
      // @drawPoints[i] = rotationX().multiply(points[i]);
      @drawPoints[i] = projection(drawPoints[i].z).multiply(drawPoints[i]);
      drawPoints[i] *= cube_scale;
    }

    angle += rotSpeed * DEG2RAD;
  }
  void pre_draw(float) {
    if(@appleE != null)
      appleE.as_controllable().sprite_index("");
  }
  void draw(float) {
    for(uint i = 0; i < points.size(); i ++) {
      drawPoints[i].draw(offsetX, offsetY, 18, 8);
    }
    //drawQuads();
    drawLines();
    
    drawFrame++;
  }

// ========Editor==========

  void editor_step() {
    offsetX = XT1 + X1;
    offsetY = YT1 + Y1;
  }

  void editor_draw(float) {
    for(uint i = 0; i < points.size(); i ++) {
      if(@points[i] != null) {
        @drawPoints[i] = points[i];
        @drawPoints[i] = rotationY().multiply(drawPoints[i]);
        @drawPoints[i] = rotationZ().multiply(drawPoints[i]);
        @drawPoints[i] = projection(drawPoints[i].z).multiply(drawPoints[i]);
        drawPoints[i] *= cube_scale;
        drawPoints[i].draw(offsetX, offsetY, 18, 8);
      }
    }
    drawLines();
  }

  void editor_var_changed(var_info@) {
    setupPoints();
  }

}
