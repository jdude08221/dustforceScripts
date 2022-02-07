
//https://en.wikipedia.org/wiki/Rotation_matrix
//https://www.youtube.com/watch?v=p4Iz0XJY-Qk
#include "jlib/math/Matrix.as"
#include "jlib/math/Vec3.as"
#include "jlib/math/3dPrismTransforms.as"

#include "jlib/const/ColorConsts.as"

#include "lib/math/math.cpp"

class script {
  [text] Prism p;
  [position,mode:world,layer:18,y:Y1] float X1;
  [hidden] float Y1;
  float rotSpeed = 2;
  float cube_scale = 5;
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
    p.init();
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
    { cos(angle), 0, sin(angle)},
    { 0, 1, 0},
    { -sin(angle), 0, cos(angle)}};
                                
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
    p.step();

    if(@entity_by_id(apple) != null) {
      @appleE = entity_by_id(apple);
    } 
    
    if(@appleE != null) {
      offsetX = appleE.x() + XT1;
      offsetY = appleE.y() + YT1;
    }

    frame++;
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
    p.draw();
    drawFrame++;
  }


  void editor_step() {
    offsetX = XT1 + X1;
    offsetY = YT1 + Y1;
  }

  void editor_draw(float) {
    p.editor_draw();
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

class Prism {
  /***Private***/
  private float offsetX;
  private float offsetY;
  //Normalize all edge lengths as 1
  private float edgeLength = 1;
  /***Public***/
  scene@ g;
  [position,mode:world,layer:18,y:Y1] float X1;
  [hidden] float Y1;
  [text] float offsetx_XT1 = -.5;
  [text] float offsety_YT1 = -.5;

  // Used to store original vertices of prism. 
  // This exists in order to avoid transforming the original points with various operations
  array<Vec3@> originalVertices(8);

  // Used to store the 2d projected vertices of the prism
  // This array is used to store vertices after being transformed for drawing
  array<Vec3@> transformedVertices(8);
  
  // Used to store the actual vertices of the prism with Z values. Used to determine draw order
  array<Vec3@> transformedVerticesProj(8);

  float originalRotation;
  
  //Potentially define as [text]
  [angle] float angle = 0;
  [slider, min:1, max:100] float z_distance = 10;
  [text] float rotationSpeed = 2;
  [slider, min:1, max:100] float cube_scale = 5;
  //----------------------------

  Prism() {
    @g = get_scene();
    fillVertexArrays();
  }

  void editor_draw() {
    for(uint i = 0; i < originalVertices.size(); i ++) {
      if(@originalVertices[i] != null) {
        @transformedVerticesProj[i] = originalVertices[i];
        @transformedVerticesProj[i] = rotationY(angle).multiply(transformedVerticesProj[i]);
        @transformedVerticesProj[i] = rotationZ(angle).multiply(transformedVerticesProj[i]);
        @transformedVerticesProj[i] = projection(z_distance, transformedVerticesProj[i].z).multiply(transformedVerticesProj[i]);
        transformedVerticesProj[i] *= cube_scale;
        transformedVerticesProj[i].draw(offsetX, offsetY, 18, 8);
      }
    }
    drawLines();
  }

  void draw() {
    //drawPoints();
    //drawLines();
    drawFaces();
  }

  void editor_step() {
    offsetX = offsetx_XT1 + X1;
    offsetY = offsety_YT1 + Y1;
  }

  void step() {
    updateOffset();
    rotate();
    angle += rotationSpeed * DEG2RAD;
  }

  void init() {
    fillVertexArrays();
  }

  void rotate(float rotx = angle, float roty = angle, float rotz = angle) {
    for(uint i = 0; i < transformedVertices.size(); i++) {
      @transformedVertices[i] = rotationY(rotx).multiply(originalVertices[i]);
      @transformedVertices[i] = rotationX(roty).multiply(transformedVertices[i]);
      @transformedVertices[i] = rotationZ(rotz).multiply(transformedVertices[i]);
      
      // @drawPoints[i] = rotationX().multiply(points[i]);
      @transformedVerticesProj[i] = projection(z_distance, transformedVertices[i].z).multiply(transformedVertices[i]);
      transformedVerticesProj[i] *= cube_scale;
      transformedVertices[i] *= cube_scale;
    }
  }

  void updateOffset(float x = 0, float y = 0) {
    offsetX = x - offsetx_XT1;
    offsetY = y - offsety_YT1;
  }

  void fillVertexArrays() {
    float halfEdge = edgeLength / 2;
    @originalVertices[0] = Vec3(offsetx_XT1, offsety_YT1, -halfEdge);
    @originalVertices[1] = Vec3(offsetx_XT1 + edgeLength, offsety_YT1, -halfEdge);
    @originalVertices[2] = Vec3(offsetx_XT1, offsety_YT1 + edgeLength, -halfEdge);
    @originalVertices[3] = Vec3(offsetx_XT1 + edgeLength, offsety_YT1 + edgeLength, -halfEdge);

    @originalVertices[4] = Vec3(offsetx_XT1, offsety_YT1, halfEdge);
    @originalVertices[5] = Vec3(offsetx_XT1 + edgeLength, offsety_YT1, halfEdge);
    @originalVertices[6] = Vec3(offsetx_XT1, offsety_YT1 + edgeLength, halfEdge);
    @originalVertices[7] = Vec3(offsetx_XT1 + edgeLength, offsety_YT1 + edgeLength, halfEdge);

    for(uint i = 0; i < originalVertices.size(); i ++) {
      @transformedVertices[i] = @originalVertices[i];
      @transformedVerticesProj[i] = @originalVertices[i];
    }
  }

  void drawPoints() {
    for(uint i = 0; i < transformedVerticesProj.size(); i ++) {
      transformedVerticesProj[i].draw(offsetX, offsetY, 18, 8);
    }
  }

  void drawLines() {
    g.draw_line_world(18, 8, transformedVerticesProj[0].x + offsetX, transformedVerticesProj[0].y + offsetY,
      transformedVerticesProj[1].x + offsetX, transformedVerticesProj[1].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[1].x + offsetX, transformedVerticesProj[1].y + offsetY,
      transformedVerticesProj[3].x + offsetX, transformedVerticesProj[3].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[3].x + offsetX, transformedVerticesProj[3].y + offsetY,
      transformedVerticesProj[2].x + offsetX, transformedVerticesProj[2].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[2].x + offsetX, transformedVerticesProj[2].y + offsetY,
      transformedVerticesProj[0].x + offsetX, transformedVerticesProj[0].y + offsetY, 5, 0xFFFFFFFF);

    //back face
    g.draw_line_world(18, 8, transformedVerticesProj[4].x + offsetX, transformedVerticesProj[4].y + offsetY,
      transformedVerticesProj[5].x + offsetX, transformedVerticesProj[5].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[5].x + offsetX, transformedVerticesProj[5].y + offsetY,
      transformedVerticesProj[7].x + offsetX, transformedVerticesProj[7].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[7].x + offsetX, transformedVerticesProj[7].y + offsetY,
      transformedVerticesProj[6].x + offsetX, transformedVerticesProj[6].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[6].x + offsetX, transformedVerticesProj[6].y + offsetY,
      transformedVerticesProj[4].x + offsetX, transformedVerticesProj[4].y + offsetY, 5, 0xFFFFFFFF);

    //Connecting Faces
    g.draw_line_world(18, 8, transformedVerticesProj[4].x + offsetX, transformedVerticesProj[4].y + offsetY,
      transformedVerticesProj[0].x + offsetX, transformedVerticesProj[0].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[5].x + offsetX, transformedVerticesProj[5].y + offsetY,
      transformedVerticesProj[1].x + offsetX, transformedVerticesProj[1].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[7].x + offsetX, transformedVerticesProj[7].y + offsetY,
      transformedVerticesProj[3].x + offsetX, transformedVerticesProj[3].y + offsetY, 5, 0xFFFFFFFF);
    g.draw_line_world(18, 8, transformedVerticesProj[6].x + offsetX, transformedVerticesProj[6].y + offsetY,
      transformedVerticesProj[2].x + offsetX, transformedVerticesProj[2].y + offsetY, 5, 0xFFFFFFFF);
  }

 //Face values are as follows:
  // Front 0
  // Left 1
  // Right 2
  // Bottom 3
  // Top 4
  // Back 5
  array<uint> drawFaces() {
    array<uint> ret(6);
    array<Quad@> faces = {
      Quad(transformedVertices[0], transformedVertices[2], transformedVertices[3], transformedVertices[1],
           transformedVerticesProj[0], transformedVerticesProj[2], transformedVerticesProj[3], transformedVerticesProj[1], COLOR_LIST[3]),
      Quad(transformedVertices[4], transformedVertices[6], transformedVertices[2], transformedVertices[0],
           transformedVerticesProj[4], transformedVerticesProj[6], transformedVerticesProj[2], transformedVerticesProj[0], COLOR_LIST[4]),
      Quad(transformedVertices[1], transformedVertices[3], transformedVertices[7], transformedVertices[5],
           transformedVerticesProj[1], transformedVerticesProj[3], transformedVerticesProj[7], transformedVerticesProj[5], COLOR_LIST[5]),
      Quad(transformedVertices[2], transformedVertices[3], transformedVertices[7], transformedVertices[6],
           transformedVerticesProj[2], transformedVerticesProj[3], transformedVerticesProj[7], transformedVerticesProj[6], COLOR_LIST[13]),
      Quad(transformedVertices[4], transformedVertices[5], transformedVertices[1], transformedVertices[0],
           transformedVerticesProj[4], transformedVerticesProj[5], transformedVerticesProj[1], transformedVerticesProj[0], COLOR_LIST[14]),
      Quad(transformedVertices[5], transformedVertices[4], transformedVertices[6], transformedVertices[7],
           transformedVerticesProj[5], transformedVerticesProj[4], transformedVerticesProj[6], transformedVerticesProj[7], COLOR_LIST[20])};
     faces.sortAsc();
    for(int i = 0; i < faces.size(); i++) {
      faces[i].draw(11 + i);
    }

    return ret;
  }

  void printMidpoints(array<Quad@> faces) {
    for(uint i = 0; i < faces.size(); i++) {
      puts(faces[i].midpoint.z);
    }
  }
}

class Quad {
  Vec3@ v1, v2, v3, v4;
  Vec3@ vd1, vd2, vd3, vd4;
  Vec3@ midpoint;
  uint color;
  scene@ g;
  Quad(Vec3@ v1i, Vec3@ v2i, Vec3@ v3i, Vec3@ v4i, Vec3@ vd1i, Vec3@ vd2i, Vec3@ vd3i, Vec3@ vd4i, uint icolor) {
    @g = get_scene();
    @v1 = v1i;
    @v2 = v2i;
    @v3 = v3i;
    @v4 = v4i;
    
    @vd1 = vd1i;
    @vd2 = vd2i;
    @vd3 = vd3i;
    @vd4 = vd4i;
    
    @midpoint = getMidpoint();
    color = icolor;
  }

  Vec3@ getMidpoint() {
    float midX = (v1.x + v2.x + v3.x + v4.x) / 4;
    float midY = (v1.y + v2.y + v3.y + v4.y) / 4;
    float midZ = (v1.z + v2.z + v3.z + v4.z) / 4;
    @midpoint = Vec3(midX, midY, midZ);
    return midpoint;
  }

  void draw(int sublayer = 19) {
   g.draw_quad_world(18, sublayer, false,
    vd1.x, vd1.y, vd2.x, vd2.y,
    vd3.x, vd3.y, vd4.x, vd4.y,
    color, color, color, color);
  }

  int opCmp (const Quad &in other) {
    return midpoint.z - other.midpoint.z;
  }
}
