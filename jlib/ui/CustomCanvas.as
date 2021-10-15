#include "Pixel.as"
#include "../const/ColorConsts.as"
/*
 * Custom Canvas class used to draw on.
 * requirements to use:
 * 1. Must call init in onLevelStart()
 * 2. Must call updatePixelSize() in step in order for
 *    brush resizing to work
 * 3. Must call draw() inside the main script's draw()
 * 4. drawCanvas() can be used inside editorDraw() to draw a canvas 
 *    preview in the editor
 */
class CustomCanvas {
  float x1, x2, y1, y2;
  array<array<Pixel@>> pixels;

  [position,mode:world,layer:18,y:Y1] float X1;
  [hidden] float Y1;
  [position,mode:world,layer:18,y:Y2] float X2;
  [hidden] float Y2;

  [hidden] float height;
  [hidden] float width;

  [hidden] float pixelSize;

  [hidden] float brush_width;
  [hidden] Rect brushRect;
  [hidden]array<Rect@> deadAreas;
  [hidden] uint cur_color;
  [hidden] bool drewLastFrame;
  [hidden] bool erasedLastFrame;
  [hidden] bool stopDrawing;
  [hidden] bool hasDeadArea;
  dictionary colors;
  scene@ g;

  CustomCanvas() {
    @g = get_scene();
    pixelSize = 10;
    cur_color = WHITE;
    brushRect = Rect(0,0,0,0);
    drewLastFrame = false;
    erasedLastFrame = false;
    stopDrawing = false;
    hasDeadArea = false;
    for(uint i = 0; i < COLOR_LIST.size(); i++) {
      colors.set(""+COLOR_LIST[i], 0);
    }
  }

  /*
   * pix_size is the size of what the canvas' NxN pixel will be
   * Called in onLevelStart()
   */
  void init(float pix_size) {
    //Update canvas resolution to fit pixels cleanly. This makes
    //Some future calculations easier (not the best design)
    updateBrushWidth(pix_size);

    pixelSize = pix_size;
    //Determining X1 and X2
    float temp = min(X1, X2);
    uint pixelWidth = uint(ceil((max(X1,X2) - temp) / pixelSize));
    X2 = temp + pixelWidth * pixelSize;
    X1 = temp;

    //Determining Y1 and Y2
    temp = min(Y1, Y2);
    uint pixelHeight = uint(ceil((max(Y1,Y2) - temp) / pixelSize));
    Y2 = temp + pixelHeight * pixelSize;
    Y1 = temp;
    //Update canvas resolution
    height = abs(Y1 - Y2);
    width = abs(X1 - X2);

    //fill pixels matrix with empty pixels
    for(uint i = 0; i < uint(height); i += uint(pixelSize)) {
      pixels.insertLast(array<Pixel@>(uint(round(width/pixelSize))));
    }
  }

  /*Used to draw the plain white canvas only*/
  void drawCanvas() {
    g.draw_rectangle_world(17, 10, X1, Y1, X2, Y2, 0, WHITE);
  }

  /* 
   * Can be used to update the pixel size on the fly.
   * Should be called in script::step()
   */
  void updatePixelSize(float size) {
    pixelSize = size;
  }

  /*
   * updates brush_width
   */
  void updateBrushWidth(float bw) {
    brush_width = bw;
  }

  /*
   * Draws a rectangle under the mouse cursor
   */
  void drawBrush() {
    //Width of black brush border
    float edge_width = 1.5;

    g.draw_rectangle_world(17, 12,
    brushRect.x1,
    brushRect.y1,
    brushRect.x2,
    brushRect.y2,
    0, BLACK);

    g.draw_rectangle_world(17, 13,
    brushRect.x1 + edge_width,
    brushRect.y1 + edge_width,
    brushRect.x2 - edge_width,
    brushRect.y2 - edge_width,
    0, cur_color);
  }

  /*
   * Takes mouse coordinates, the brush_width, and current 
   * brush color as arguments
   * 
   * Used to update brush preview coordinates as well as to determine
   * if the brush is inside the canvas and thus, should be drawn
   */
  void updateBrushPos(float mouse_x, float mouse_y) {
    //Only draw if mouse is inside canvas
    float br = brush_width/2;

    if(insideCanvas(mouse_x, mouse_y)) {
      float relX = 0;
      float relY = 0;
      if(brush_width > pixelSize) {
        relX = max(mouse_x-br, min(X1, X2)) - min(X1, X2);
        relY = max(mouse_y-br, min(Y1, Y2)) - min(Y1, Y2);
      } else {
        relX = abs(max(mouse_x, min(X1, X2)) - min(X1, X2));
        relY = abs(max(mouse_y, min(Y1, Y2)) - min(Y1, Y2));
      }
      
      
      float numPixelsHorz = floor(relX / pixelSize);
      float numPixelsVert = floor(relY / pixelSize);
      //Ensure brush stays inside canvas and tapers off as you move off the canvas
       float brushX1 = max(min(X1,X2) + uint(numPixelsHorz * pixelSize), min(X1, X2));
       float brushX2 = min(min(X1,X2) + uint(numPixelsHorz * pixelSize) + brush_width, max(X1, X2));
       float brushY1 = max(min(Y1,Y2) + uint(numPixelsVert * pixelSize), min(Y1, Y2));
       float brushY2 = min(min(Y1,Y2) + uint(numPixelsVert * pixelSize) + brush_width, max(Y1, Y2));
      
      // Both if statements here handle if we go off the left or top of canvas
      if(mouse_x - br < min(X1, X2)) {
       float relXTemp = abs(mouse_x - br - min(X1, X2));
       brushX2 = min(min(X1,X2) + uint(numPixelsHorz * pixelSize) + brush_width, max(X1, X2)) - 
        uint(floor(relXTemp / pixelSize) * pixelSize);
      }

      if(mouse_y - br < min(Y1, Y2)) {
       float relYTemp = abs(mouse_y - br - min(Y1, Y2));
       brushY2 = min(min(Y1,Y2) + uint(numPixelsVert * pixelSize) + brush_width, max(Y1, Y2)) - 
        uint(floor(relYTemp / pixelSize) * pixelSize);
      }

      brushRect.x1 = brushX1;
      brushRect.x2 = brushX2;
      brushRect.y1 = brushY1;
      brushRect.y2 = brushY2;
    } else {
      //Set brush to have 0 area to make it not visible
      brushRect.x1 = 0;
      brushRect.x2 = 0;
      brushRect.y1 = 0;
      brushRect.y2 = 0;
    }
  }

  /*
   * Takes mouse coordinates (mouse_x, mouse_y) as arguments
   * returns bool dennoting if mouse is within canvas area
   */
  bool insideCanvas(float mouse_x, float mouse_y) {
    float mx = floor(mouse_x);
    float my = floor(mouse_y);
    float br = brush_width/2;
    if(hasDeadArea) {
      for(uint i = 0; i < deadAreas.size(); i++) {
        Rect deadArea = deadAreas[i];
        if(mx >= deadArea.x1 && mx <= deadArea.x2 && my >= deadArea.y1 && my <= deadArea.y2) {
          return false;
        }
      }
    }
    //Allows mouse to go off top left of canvas
    return (mx) <= max(X1, X2) + br && (mx) >= min(X1, X2)-br &&
           (my) < max(Y1, Y2) + br && (my) >= min(Y1, Y2)-br;
  }

  /*
   * Takes mouse coordinates (mouse_x, mouse_y), 
   * brush width (brush_width), and current selected color as arguments
   * Handles all logic needed for drawing canvas, brush, and pixels
   * Must be called inside script::draw()
   */
  void draw(float mouse_x, float mouse_y, uint color) {
    cur_color = color;

    //Stop allowing user input
    if(stopDrawing) {
      //Draw the pixels on the canvas
      drawCanvas();
      drawPixels();
      return;
    }

    //Update the brush preview
    updateBrushPos(mouse_x, mouse_y);

    //Draw the White Canvas
    drawCanvas();
    
    //Draw the brush preview
    drawBrush();
    
    //Draw the pixels on the canvas
    drawPixels();

    //reset the drawing state
    resetDraw();
  }

  /*
   * Takes mouse coordinates (mouse_x, mouse_y) as arguments
   * should be called whenever you want to draw pixels and
   * store them to the canvas. returns true if called while mouse
   * is inside the canvas
   */
  bool addPixels(float mouse_x, float mouse_y) {
    drewLastFrame = false;
    erasedLastFrame = false;
    //If we are using white, just make the pixels null to save on computation
    if(cur_color == WHITE) {
      removePixels(mouse_x, mouse_y, true);
      return true;
    } else if(insideCanvas(mouse_x, mouse_y)) {
      //Iterate over each pixel inside the brush rectangle
      for(float i = brushRect.y1; i < brushRect.y2; i += pixelSize) {
        for(float j = brushRect.x1; j < brushRect.x2; j += pixelSize) {
          //Determine the rect that bounds the pixel
          float pixelX1 = j;
          float pixelX2 = j + pixelSize;
          float pixelY1 = i;
          float pixelY2 = i + pixelSize;

          Pixel@ d = Pixel(Rect(pixelX1, pixelY1, pixelX2, pixelY2), cur_color);

          //Get the pixel's relative x,y position to the canvas.
          //Canvas resolution is determined by its real dustforce size
          //divided up into pixel sized units
          //top of canvas is considered 0,0
          float relX = abs(max(pixelX1, X1) - min(pixelX1, X1));
          float relY = abs(max(pixelY1, Y1) - min(pixelY1, Y1));

          //Determine where in the canvas matrix we want to place the pixel
          //And save it
          uint index_i = uint(floor(relY/pixelSize));
          uint index_j = uint(floor(relX/pixelSize));

          if(@pixels[index_i][index_j] == null ||
            pixels[index_i][index_j].color != cur_color) {
            colors[""+d.color] = uint(colors[""+d.color]) + 1;
            drewLastFrame = true;
          }
            
            pixels[index_i].removeAt(index_j);
            pixels[index_i].insertAt(index_j, d);
        }
      }
      return true;
    }
    return false;
  }

  /*
   * Takes mouse coordinates (mouse_x, mouse_y) as arguments, as well as a bool that
   * dennotes if we are actually painting white (which is handled by erasing)
   * should be called whenever you want to remove pixels from the canvas
   * returns true if called when mouse is inside the canvas
   */
  bool removePixels(float mouse_x, float mouse_y, bool painting = false) {
    if(insideCanvas(mouse_x, mouse_y)) {
      //Iterate over each pixel inside the brush rectangle
      for(float i = brushRect.y1; i < brushRect.y2; i += pixelSize) {
        for(float j = brushRect.x1; j < brushRect.x2; j += pixelSize) {
          //Determine the pixels the brush currently is over, 
          //and remove them from their x/y position in the pixels matrix
          float pixelX1 = j;
          float pixelY1 = i;
          float relX = abs(max(pixelX1, X1) - min(pixelX1, X1));
          float relY = abs(max(pixelY1, Y1) - min(pixelY1, Y1));
          uint index_i = uint(floor(relY/pixelSize));
          uint index_j = uint(floor(relX/pixelSize));

          if(@pixels[index_i][index_j] != null &&
            pixels[index_i][index_j].color != WHITE) {
            if(painting) {
              drewLastFrame = true;
            } else {
              uint count = uint(colors[""+pixels[index_i][index_j].color]);
              colors[""+pixels[index_i][index_j].color] = count > 0 ? count - 1 : count;
              erasedLastFrame = true;
            }
          }
          
          pixels[index_i].removeAt(index_j);
          pixels[index_i].insertAt(index_j, null);
        }
      }
      return true;
    }
    return false;
  }

  /*
   * Draws pixels currently stored in canvas matrix to the scene
   */
  void drawPixels() {
    for(uint i = 0; i < pixels.size(); i++) {
      for(uint j = 0; j < pixels[i].size(); j++) {
        if(@pixels[i][j] != null) {
          g.draw_rectangle_world(17, 11,
          pixels[i][j].rect.x1,
          pixels[i][j].rect.y1,
          pixels[i][j].rect.x2,
          pixels[i][j].rect.y2,
          0, pixels[i][j].color
          );
        }
      }
    }
  }
  
  /*
   * Called at the end of draw() to reset what was done last frame
   */
  void resetDraw() {
    drewLastFrame = false;
    erasedLastFrame = false;
  }

  uint getNumColors() {
    uint ret = 0;
    for(uint i = 0; i < COLOR_LIST.size(); i++) {
      ret += uint(colors[""+COLOR_LIST[i]]) > 0 ? 1 : 0;
    }
    return ret;
  }

  /*
   * Can be called to disallow further drawing. Canvas and current drawing
   * so far will still be drawn however
   */
  void disableDrawing() {
    stopDrawing = true;
  }

  /*
  * Sets up a dead area where mouse shouldnt paint. Can be used to avoid 
  * drawing when mouse is in certain areas. Takes a rectangle where mouse 
  * should not be allowed to draw
  */
  void setDeadArea(Rect r) {
    hasDeadArea = true;
    deadAreas.insertLast(r);
  }
}