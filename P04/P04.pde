/**************************** HEADER ****************************
 LecturesInGraphics: Template for Processing sketches in 2D
 Template author: Jarek ROSSIGNAC
 Class: CS3451 Fall 2014
 Student: Miranda Bradley
 Project number: 5
 Project title: Graphs -> 3D extruded geo
 Date of submission: ??
 *****************************************************************/
import processing.opengl.*;
import javax.media.opengl.*;
import java.nio.*;

//**************************** global variables ****************************

//*************** text drawn on the canvas for name, title and help  *******************
String title ="CS3451, Fall 2014, Project 05: Graph -> 3D Geo", name ="Miranda Bradley", // enter project number and your name
menu="'q' drag new vertex from prev, 'w' connect two existing verts, 'e' delete vert, 'r' add vert", 
guide="Press&drag mouse to move dot. 'x', 'y' restrict motion, 'p' toggle 2D/3D, 'f' focus"; // help info
// velocityDisplay=Float.toString(velocity)

//geo for the graph
ArrayList<Corner> masterCs = new ArrayList<Corner>();
ArrayList<Vertex> masterVs = new ArrayList<Vertex>();
ArrayList<Integer> masterFs = new ArrayList<Integer>();

//store all the geo for the 3D faces
ArrayList<Geo3D> faces3D = new ArrayList<Geo3D>();

int outerFace = -1;

VertexHandler vertexHandler = new VertexHandler();
boolean  singlePress = false;
boolean editStart = true;
boolean editing = false;
boolean connectingTwoExisting = false;
boolean connectClick1 = false;
boolean notDrawn = true;
boolean removeVert = false;
boolean mouseClicked = false;
boolean addVert = false;
boolean in3D = false;
boolean centered = true;
int prevConnect = -1;
float area3D = 0.0f;
PVector center = new PVector(0,0);
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI; 
float dz=0;
//float rx = 0f, ry = 0f; 

int swingRedraw, prevRedraw, nextRedraw;

Vertex rubberBand = new Vertex();

boolean mouseDragged, editMode;
PVector mouseDragStart;

int selectedVertexID = -1;

pt F = P(0,0,0); 

//**************************** initialization ****************************
void setup() {               // executed once at the begining
  //size(600, 600);            // window size 
  size(600, 600, P3D);            // window size
  lights();
  frameRate(30);             // render 30 frames per second
  noSmooth();                  // turn on antialiasing
  myFace = loadImage("data/pic.jpg");  // loads image from file pic.jpg in folder data, replace it with a clear pic of your face

  editMode = false;
  swingRedraw = prevRedraw = nextRedraw = -1;
  
  //hard coded points! for testing
  vertexHandler.AddVertex(50, 200, 0, -1, masterVs, masterCs, masterFs);
  vertexHandler.AddVertex(50, 400, 0, 0, masterVs, masterCs, masterFs);
  vertexHandler.AddVertex(250, 400, 0, 1, masterVs, masterCs, masterFs);
  //vertexHandler.AddVertex(250, 200, 0, 2, masterVs, masterCs, masterFs);
  //vertexHandler.AddVertex(250, 200, 0, 0, masterVs, masterCs, masterFs);
//  vertexHandler.AddVertex(50, 400, 0, 3, masterVs, masterCs, masterFs);

}

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  pen(black, 3); // sets stroke color (to balck) and width (to 3 pixels)
  //println(mousepos.x, mousepos.y, mousepos.z);

  if (keyPressed) {
    fill(black); 
    text(key, mouseX-2, mouseY);
  } // writes the character of key if still pressed

  if (filming && (animating || change)) saveFrame("FRAMES/"+nf(frameCounter++, 4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
  // make sure that animating is set to true at the beginning of an animation and to false at the end

  displayHeader();
  if (!mousePressed && !keyPressed)
    //scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed
  if (scribeText && !filming)
    displayFooter(); // shows title, menu, and my face & name 

  //rotate based on user input
  if(centered) translate(-F.x,-F.y,-F.z);
  rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
  translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
  //rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor

  if(in3D) {
    area3D = 0f;
    //draw verts/edges for each face
    for(Geo3D c: faces3D) {
      DrawAllGeo(c.geoVs, c.geoCs, c.geoFs, c.nextRedraw, c.prevRedraw, c.swingRedraw);
      //println("finished draw all geo");
      if (c.geoFs.size() > 1) {
        int faceToDraw = MouseIsWithinFace(c.outerFace, c.geoVs, c.geoCs, c.geoFs);
        if (faceToDraw != -1) {
         // DrawFaceSidewalks(faceToDraw, c.geoVs, c.geoCs, c.geoFs);
        } else {
          //DrawFaceSidewalks(c.outerFace, c.geoVs, c.geoCs, c.geoFs);
          //println("finished drawing face sidewalks");
        }
      }
      if(c.geoFs.size() > 1)area3D += Calculate3DArea(c.geoVs, c.geoCs, c.geoFs);
      //println("finished Calculate3DArea");

      CheckForVertexHover(c.geoVs, c.geoCs, c.geoFs, c.nextRedraw, c.prevRedraw, c.swingRedraw);
      //println("finished CheckForVertexHover");

    }
    //println("area3D: "+area3D);

    //display total area of the face in this plane
    fill(areaColor);
    textSize(areaTextSize);
    textAlign(CENTER);
    String areaText = String.format("%.0f", area3D);
    text(areaText, center.x, center.y+10);
    textAlign(LEFT);

    showWalls();
    //interactive corner drawing

    //need to handle interactivity differently here since cycling through multiple faces
    //determine which set we currently care about

  } else {
    DrawAllGeo(masterVs, masterCs, masterFs, nextRedraw, prevRedraw, swingRedraw);

    if (masterFs.size() > 1) {
      int faceToDraw = MouseIsWithinFace(outerFace, masterVs, masterCs, masterFs);
      if (faceToDraw != -1) {
        DrawFaceSidewalks(faceToDraw, masterVs, masterCs, masterFs);
        DrawAreaOfFace(faceToDraw, masterVs, masterCs, masterFs);
      } else {
        DrawFaceSidewalks(outerFace, masterVs, masterCs, masterFs);
        DrawAreaOfFace(outerFace, masterVs, masterCs, masterFs);
      }
    }

    // MOUSE INTERACTION STUFF
    if (selectedVertexID != -1) {
      // vertex has been selected already
      Vertex v = new Vertex();

      //if looking to connect
      if(connectingTwoExisting){
        if(connectClick1){
          //println("stored prev click " + selectedVertexID);
          prevConnect = selectedVertexID;
          connectClick1 = false;
        } else if (!connectClick1){
          if((selectedVertexID != prevConnect) && notDrawn){
            //println("connected to : "+ selectedVertexID );
            v = GetVertexFromID(prevConnect, masterVs);
            notDrawn = vertexHandler.AddVertex((int)v.pos.x, (int)v.pos.y, 0, selectedVertexID, masterVs, masterCs, masterFs);
            if(notDrawn == false) {
              Vertex otherVert = GetVertexFromID(selectedVertexID, masterVs);
              notDrawn = vertexHandler.AddVertex((int)otherVert.pos.x, (int)otherVert.pos.y, 0, v.id, masterVs, masterCs, masterFs);
            }
            notDrawn = !notDrawn;
          }
        }
      } else if (removeVert) { //NEED TO CHECK THESE FNS FOR WHICH ARRAY LIST WE CURRENTLY CARE ABOUT
        //println("remove the vert");
        boolean removable = vertexHandler.CheckIfRemovable(GetVertexFromID(selectedVertexID, masterVs));
        if(removable) {
          vertexHandler.RemoveVertex(selectedVertexID, masterVs, masterCs, masterFs);
          //selectedVertexID = -1;
        }
      } else {
        v = GetVertexFromID(selectedVertexID, masterVs);
        v.isInteracted(masterVs, masterCs, masterFs);
      }
    } else {
      // vertex has not been selected yet
      CheckForVertexHover(masterVs, masterCs, masterFs, nextRedraw, prevRedraw, swingRedraw);
    }  
  } //end 2D drawing

}  // end of draw()

void DrawAllGeo(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs, int _nextRedraw, int _prevRedraw, int _swingRedraw){
  displayVertices(_mastVs);
  displayEdges(_mastVs, _mastCs, _mastFs);
  displayCorners(_mastVs, _mastCs, _nextRedraw, _prevRedraw, _swingRedraw);
}

public pt pick(int mX, int mY) //given fn by TA & Professor for picking a point in 3D with mouse
{
  PGL pgl = beginPGL();
  FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.

  nativeOrder()).asFloatBuffer();
  pgl.readPixels(mX, height - mY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
  float depthValue = depthBuffer.get(0);
  depthBuffer.clear();
  endPGL();

  //get 3d matrices
  PGraphics3D p3d = (PGraphics3D)g;
  PMatrix3D proj = p3d.projection.get();
  PMatrix3D modelView = p3d.modelview.get();
  PMatrix3D modelViewProjInv = proj; modelViewProjInv.apply( modelView ); modelViewProjInv.invert();
  
  float[] viewport = {0, 0, p3d.width, p3d.height};
  
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = depthValue * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  
  float[] unprojected = new float[4];
  
  modelViewProjInv.mult( normalized, unprojected );
  return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
}

//************************* mouse and key actions ****************************
void keyPressed() { // executed each time a key is pressed: the "key" variable contains the correspoinding char, 
  if (key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if (key=='!') snapPicture(); // make a picture of the canvas
  if (key=='~') { 
    filming=!filming;
  } // filming on/off capture frames into folder FRAMES
  if (key==' ') {
   // MouseIsWithinFace();
  } // reset the blue ball at the center of the screen
  if (key=='a') animating=true;  // quit application
  if (key=='Q') exit();  // quit application
  change=true;

  if (key == 'q') {
    if(!singlePress){
      editing = true;
      editMode = true;
      singlePress = true;
    }
  }

  if(key == 'w'){
    if(!singlePress){
      connectingTwoExisting = true;
      connectClick1 = true;
      singlePress = true;
      notDrawn = true;
    }
  }

  if(key == 'e'){
    removeVert = true;
  }

  if(key == 'r') {
    addVert = true;
  }

  if(key == 'p'){
    in3D = !in3D;
    SetupModeSwitch();
  }

//rotation stuff
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
}

void mouseWheel(MouseEvent event) {dz -= event.getAmount(); change=true;}

void keyReleased() { // executed each time a key is released
  if (key=='b') {

  }

  if(key == 'r') {
    addVert = false;
  }
  if (key=='a') animating=false;  // quit application
  change=true;

  if (key == 'q') {
    editing = false;
    if(singlePress){
      editMode = false;
      singlePress = false;
    }
  }

  if(key == 'w'){
    singlePress = false;
    connectingTwoExisting = false;
  }

  if(key == 'e'){
    removeVert = false;
  }
}

void mouseDragged() { // executed when mouse is pressed and moved
  change=true;
  mouseDragged = true;

  if (keyPressed && key=='f') { // move focus point on plane
    if(centered) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  }
}

void mouseMoved() { // when mouse is moved
  change=true;
}

void mousePressed(MouseEvent e) { // when mouse key is pressed 
  mouseDragStart = new PVector(mouseX, mouseY);
  mouseClicked = true;
}

void mouseReleased(MouseEvent e) { // when mouse key is released 
  mouseDragStart = new PVector();
  mouseDragged = false;
  selectedVertexID = -1;
  mouseClicked = false;
}

void mouseClicked(MouseEvent e) {
  
}

public Corner GetCornerFromID(int cornerID, ArrayList<Corner> _mastCs) {
  return _mastCs.get(cornerID);
}

public Corner GetCornerFromFaceID(int faceID, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  return GetCornerFromID(_mastFs.get(faceID), _mastCs);
}
 
public Vertex GetVertexFromCornerID(int cornerID, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs) {
  return _mastVs.get(_mastCs.get(cornerID).vertex);
}

public Vertex GetVertexFromID(int vertexID, ArrayList<Vertex> _mastVs) {
  return _mastVs.get(vertexID);
}

public void CheckForFaces(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  ArrayList<Corner> unvisitedCorners = new ArrayList<Corner>();
  unvisitedCorners = _mastCs;
  ArrayList<Integer> unvisitedCornerIDs = new ArrayList<Integer>();

  while (unvisitedCornerIDs.size() < _mastCs.size()) {
    unvisitedCorners.get(unvisitedCornerIDs.size()).visited = false;
    unvisitedCornerIDs.add(_mastCs.get(unvisitedCornerIDs.size()).id);
  }

  _mastFs.clear();

  int numUnvisitedCorners = 0;
  int currentCornerID = 0;
  while (numUnvisitedCorners < unvisitedCorners.size() && currentCornerID < unvisitedCorners.size()) {
    currentCornerID = 0;
    while (currentCornerID < unvisitedCorners.size()) {
      if (unvisitedCorners.get(currentCornerID).visited || !unvisitedCorners.get(currentCornerID).exists()) {
        currentCornerID++;
      } else {
        break;
      }
    }

    // THIS IS SUPER DUMB
    if (currentCornerID >= unvisitedCorners.size()) {
      break;
    }

    Corner currCorner = GetCornerFromID(currentCornerID, _mastCs);
    Vertex currVertex = GetVertexFromCornerID(currentCornerID, _mastVs, _mastCs);

    PVector currPos = currVertex.pos;
    PVector prevPos = GetVertexFromCornerID(currCorner.prev, _mastVs, _mastCs).pos;
    PVector nextPos = GetVertexFromCornerID(currCorner.next, _mastVs, _mastCs).pos;
    
    PVector fromPrev = new PVector(currPos.x - prevPos.x, currPos.y - prevPos.y);
    PVector toNext = new PVector(nextPos.x - currPos.x, nextPos.y - currPos.y);
    if (det(fromPrev, toNext) < 0) {
      // counter-clockwise corner, must be outer face
      outerFace = _mastFs.size();
      //println("outer face = " + outerFace);
    }
    _mastFs.add(currentCornerID);

    while (!unvisitedCorners.get(currentCornerID).visited) {
      unvisitedCorners.get(currentCornerID).visited = true;
      currentCornerID = unvisitedCorners.get(currentCornerID).next;
      numUnvisitedCorners++;
    }
  }

  //println("FACES: " + masterFs);
}

void CheckForVertexHover(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs, int _nextRedraw, int _prevRedraw, int _swingRedraw){
    //interactive vert drawing
  for (int i = 0; i < _mastVs.size(); i++) {
    Vertex v = GetVertexFromID(i, _mastVs);
    if (v.exists()) {
      v.isInteracted(_mastVs, _mastCs, _mastFs);
    }
  }

  Corner interactCorner = GetCornerFromID(0, _mastCs);
  boolean newInteract = false;
  for (int i = 0; i < _mastCs.size(); i++) {
    Corner corner = GetCornerFromID(i, _mastCs);
    if (corner.exists()) {
      boolean interact = corner.isInteracted(_mastVs, _mastCs);
      if(interact) {
        interactCorner = corner;
        newInteract = true;
      }
    }
  }

  if(newInteract) {
    _nextRedraw = interactCorner.next;
    _prevRedraw = interactCorner.prev;
    _swingRedraw = interactCorner.swing;
  }
  //handle next and swing
  if(_nextRedraw != -1) {
    GetCornerFromID(_nextRedraw, _mastCs).Draw(nextColor, _mastVs, _mastCs, _prevRedraw, _nextRedraw, _swingRedraw);
    if(_swingRedraw != -1) GetCornerFromID(_swingRedraw, _mastCs).Draw(swingColor, _mastVs, _mastCs, _prevRedraw, _nextRedraw, _swingRedraw);
    GetCornerFromID(_prevRedraw, _mastCs).Draw(prevColor, _mastVs, _mastCs, _prevRedraw, _nextRedraw, _swingRedraw);
  }
}

public int MouseIsWithinFace(int _outerFace, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  // return which face the mouse is within
  for (int i = 0; i < _mastFs.size(); i++) {   ///////////////////////////////////////////////////
    if (i != _outerFace) {
      int intersections = 0;
      int startCornerID = _mastFs.get(i);
      Corner startCorner = GetCornerFromID(startCornerID, _mastCs);
      int currentCornerID = startCornerID;
      ////println("mouse in face for");
      do {
        ////println("mouse in face: " + i + " -> " + currentCornerID);
        Corner currentCorner = GetCornerFromID(currentCornerID, _mastCs);
        Vertex currentVertex = GetVertexFromCornerID(currentCornerID, _mastVs, _mastCs);

        if (!currentCorner.exists()) {
          CheckForFaces(_mastVs, _mastCs, _mastFs);
          MouseIsWithinFace(_outerFace, _mastVs, _mastCs, _mastFs);
          break;
        }

        Vertex nextVertex = GetVertexFromCornerID(currentCorner.next, _mastVs, _mastCs);

        PVector start = currentVertex.pos;
        PVector end = nextVertex.pos;

        if (HorizontalIntersectsLineSegment(mouseY, start, end)) {
          intersections++;
        }

        currentCornerID = currentCorner.next;
      } while (currentCornerID != startCornerID);

      ////println("face " + i + " intersections: " + intersections);

      if (intersections % 2 != 0) {
        return i;
      }
    } else {
      if (!GetCornerFromID(_mastFs.get(_outerFace), _mastCs).exists()) {
        CheckForFaces(_mastVs, _mastCs, _mastFs);
        MouseIsWithinFace(_outerFace, _mastVs, _mastCs, _mastFs);
        break;
      }
    }
  }

  return -1;
}

public boolean HorizontalIntersectsLineSegment(float y, PVector a, PVector b) {
  // y : horizontal line y-value
  // ab : line segment
  //PVector c = new PVector(min(a.x, b.x)-20, y);
  //PVector d = new PVector(max(a.x, b.x)+20, y);
  float m = (b.y - a.y) / (b.x - a.x);
  float intercept = a.y - m*a.x;
  float x = (y-intercept)/m;

  if (a.x == b.x) {
    // if ab is vertical line, return true if y is between a.y and b.y
    // print(" // " + (y <= max(a.y, b.y) && y >= min(a.y, b.y)) + "\n");
    // return (y <= max(a.y, b.y) && y >= min(a.y, b.y));
    x = a.x;
  }

  // print("a " + a + ", b " + b + ", m " + m + ", int " + intercept + ", x " + x + ", y " + y);

  if (a.y == b.y) {
    // if ab is a horizontal line, return true if y is equal to a.y
    // print(" // " + false + "\n");
    return false;
  } 

  // print(" // " + (x >= mouseX && y <= max(a.y, b.y) && y >= min(a.y, b.y)) + "\n");
  return (x >= mouseX && y <= max(a.y, b.y) && y >= min(a.y, b.y));
}

public float DrawAreaOfFace(int faceID, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  float area = 0f;
  center = new PVector(0, 0);
  int numCorners = 0;

  int startCornerID = _mastFs.get(faceID);
  Corner startCorner = GetCornerFromID(startCornerID, _mastCs);
  int currentCornerID = startCornerID;

  do {
    Corner currentCorner = GetCornerFromID(currentCornerID, _mastCs);
    Vertex currentVertex = GetVertexFromCornerID(currentCornerID, _mastVs, _mastCs);
    Vertex nextVertex = GetVertexFromCornerID(currentCorner.next, _mastVs, _mastCs);

    PVector start = currentVertex.pos;
    PVector end = nextVertex.pos;

    numCorners++;
    center.add(start);
    area += (end.x + start.x) * (end.y - start.y) / 2;

    currentCornerID = currentCorner.next;
  } while (currentCornerID != startCornerID);

  center.div(numCorners);

  fill(areaColor);
  textSize(areaTextSize);
  textAlign(CENTER);

  String areaText = String.format("%.0f", abs(area));
  text(areaText, center.x, center.y+10);
  textAlign(LEFT);
  return area;
}

public float Calculate3DArea(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  float area = 0f;
  PVector center = new PVector(0, 0);
  int numCorners = 0;

  int startCornerID = _mastFs.get(1);
  Corner startCorner = GetCornerFromID(startCornerID, _mastCs);
  int currentCornerID = startCornerID;

  do {
    Corner currentCorner = GetCornerFromID(currentCornerID, _mastCs);
    Vertex currentVertex = GetVertexFromCornerID(currentCornerID, _mastVs, _mastCs);
    Vertex nextVertex = GetVertexFromCornerID(currentCorner.next, _mastVs, _mastCs);

    PVector start = currentVertex.pos;
    PVector end = nextVertex.pos;

    numCorners++;
    center.add(start);
    area += (end.x + start.x) * (end.y - start.y) / 2;

    currentCornerID = currentCorner.next;
  } while (currentCornerID != startCornerID);

  center.div(numCorners);

  return area;
}

void SetupModeSwitch() {
  if(in3D) {
    println("3d mode");
    CalculateSidewalkGeo();
  }
}
