/**************************** HEADER ****************************
 LecturesInGraphics: Template for Processing sketches in 2D
 Template author: Jarek ROSSIGNAC
 Class: CS3451 Fall 2014
 Student: Miranda Bradley and Sebastian Monroy
 Project number: 4
 Project title: Graphs!
 Date of submission: ??
 *****************************************************************/


//**************************** global variables ****************************

//*************** text drawn on the canvas for name, title and help  *******************
String title ="CS3451, Fall 2014, Project 04: Graphs!", name ="Miranda Bradley and Sebastian Monroy", // enter project number and your name
menu="'q' drag new vertex from prev, 'w' connect two existing verts, 'e' delete vert", 
guide="Press&drag mouse to move dot. 'x', 'y' restrict motion"; // help info
// velocityDisplay=Float.toString(velocity)

ArrayList<Corner> masterCs = new ArrayList<Corner>();
ArrayList<Vertex> masterVs = new ArrayList<Vertex>();
ArrayList<Integer> masterFs = new ArrayList<Integer>();

int outerFace = -1;

VertexHandler vertexHandler = new VertexHandler();
boolean  singlePress = false;
boolean editStart = true;
boolean editing = false;
boolean connectingTwoExisting = false;
boolean connectClick1 = false;
boolean notDrawn = true;
boolean removeVert = false;
int prevConnect = -1;

int swingRedraw, prevRedraw, nextRedraw;

Vertex rubberBand = new Vertex();

boolean mouseDragged, editMode;
PVector mouseDragStart;

int selectedVertexID = -1;

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(600, 600);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/pic.jpg");  // loads image from file pic.jpg in folder data, replace it with a clear pic of your face
  myFace2 = loadImage("data/pic2.jpg");

  editMode = false;
  swingRedraw = prevRedraw = nextRedraw = -1;
  
  //hard coded points! for testing
  vertexHandler.AddVertex(100, 100, -1);
  vertexHandler.AddVertex(100, 300, 0);
  vertexHandler.AddVertex(300, 300, 1);
  vertexHandler.AddVertex(300, 100, 2);
  vertexHandler.AddVertex(300, 100, 0);
  vertexHandler.AddVertex(100, 300, 3);
  // vertexHandler.AddVertex(300, 300, 0);
 // vertexHandler.AddVertex(100, 100, 2);
  
  //PVector temp = new PVector(-1,0);
  //println("/////////" + temp.heading());
}

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  pen(black, 3); // sets stroke color (to balck) and width (to 3 pixels)

  if (keyPressed) {
    fill(black); 
    text(key, mouseX-2, mouseY);
  } // writes the character of key if still pressed

  if (filming && (animating || change)) saveFrame("FRAMES/"+nf(frameCounter++, 4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
  // make sure that animating is set to true at the beginning of an animation and to false at the end

  displayEdges();
  displayVertices();

  if (masterFs.size() > 1) {
    int faceToDraw = MouseIsWithinFace();
    if (faceToDraw != -1) {
      DrawFaceSidewalks(faceToDraw);
      DrawAreaOfFace(faceToDraw);
    } else {
      DrawFaceSidewalks(outerFace);
      DrawAreaOfFace(outerFace);
    }
  }

  displayCorners();

  if(nextRedraw != -1) {
    GetCornerFromID(nextRedraw).Draw(nextColor);
    if(swingRedraw != -1) GetCornerFromID(swingRedraw).Draw(swingColor);
    GetCornerFromID(prevRedraw).Draw(prevColor);
  }

  displayHeader();
  if (!mousePressed && !keyPressed)
    scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed
  if (scribeText && !filming)
    displayFooter(); // shows title, menu, and my face & name 

  // MOUSE INTERACTION STUFF
  if (selectedVertexID != -1) {
    // vertex has been selected already
    Vertex v = new Vertex();

    //if looking to connect
    if(connectingTwoExisting){
      if(connectClick1){
        println("stored prev click " + selectedVertexID);
        prevConnect = selectedVertexID;
        connectClick1 = false;
      } else if (!connectClick1){
        if((selectedVertexID != prevConnect) && notDrawn){
          println("connected to : "+ selectedVertexID );
          v = GetVertexFromID(prevConnect);
          notDrawn = vertexHandler.AddVertex((int)v.pos.x, (int)v.pos.y, selectedVertexID);
          if(notDrawn == false) {
            Vertex otherVert = GetVertexFromID(selectedVertexID);
            notDrawn = vertexHandler.AddVertex((int)otherVert.pos.x, (int)otherVert.pos.y, v.id);
          }
          notDrawn = !notDrawn;
        }
      }
    } else if(removeVert) {
      println("remove the vert");
      boolean removable = vertexHandler.CheckIfRemovable(GetVertexFromID(selectedVertexID));
      if(removable) vertexHandler.RemoveVertex(selectedVertexID);
    } else {
      v = GetVertexFromID(selectedVertexID);
      v.isInteracted();
    }
  } else {
    // vertex has not been selected yet
    for (int i = 0; i < masterVs.size(); i++) {
      Vertex v = GetVertexFromID(i);
      v.isInteracted();
    }

    for (int i = 0; i < masterCs.size(); i++) {
      Corner c = GetCornerFromID(i);
      c.isInteracted();
    }
  }  
}  // end of draw()


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
}

void keyReleased() { // executed each time a key is released
  if (key=='b') {

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
}

void mouseMoved() { // when mouse is moved
  change=true;
}

void mousePressed(MouseEvent e) { // when mouse key is pressed 
  mouseDragStart = new PVector(mouseX, mouseY);
}

void mouseReleased(MouseEvent e) { // when mouse key is released 
  mouseDragStart = new PVector();
  mouseDragged = false;
  selectedVertexID = -1;
}

public Corner GetCornerFromID(int cornerID) {
  return masterCs.get(cornerID);
}

public Corner GetCornerFromFaceID(int faceID) {
  return GetCornerFromID(masterFs.get(faceID));
}
 
public Vertex GetVertexFromCornerID(int cornerID) {
  return masterVs.get(masterCs.get(cornerID).vertex);
}

public Vertex GetVertexFromID(int vertexID) {
  return masterVs.get(vertexID);
}

public void CheckForFaces() {
  ArrayList<Corner> unvisitedCorners = new ArrayList<Corner>();
  unvisitedCorners = masterCs;
  ArrayList<Integer> unvisitedCornerIDs = new ArrayList<Integer>();

  while (unvisitedCornerIDs.size() < masterCs.size()) {
    unvisitedCorners.get(unvisitedCornerIDs.size()).visited = false;
    unvisitedCornerIDs.add(masterCs.get(unvisitedCornerIDs.size()).id);
  }

  masterFs.clear();

  int numUnvisitedCorners = 0;
  int currentCornerID;
  while (numUnvisitedCorners < unvisitedCorners.size()) {
    currentCornerID = 0;
    while (currentCornerID < unvisitedCorners.size()) {
      if (unvisitedCorners.get(currentCornerID).visited) {
        currentCornerID++;
      } else {
        break;
      }
    }

    Corner currCorner = GetCornerFromID(currentCornerID);
    Vertex currVertex = GetVertexFromCornerID(currentCornerID);

    PVector currPos = currVertex.pos;
    PVector prevPos = GetVertexFromCornerID(currCorner.prev).pos;
    PVector nextPos = GetVertexFromCornerID(currCorner.next).pos;
    
    PVector fromPrev = new PVector(currPos.x - prevPos.x, currPos.y - prevPos.y);
    PVector toNext = new PVector(nextPos.x - currPos.x, nextPos.y - currPos.y);
    if (det(fromPrev, toNext) < 0) {
      // counter-clockwise corner, must be outer face
      outerFace = masterFs.size();
    }
    masterFs.add(currentCornerID);

    while (!unvisitedCorners.get(currentCornerID).visited) {
      unvisitedCorners.get(currentCornerID).visited = true;
      currentCornerID = unvisitedCorners.get(currentCornerID).next;
      numUnvisitedCorners++;
    }
  }

  println("FACES: " + masterFs);
}

public int MouseIsWithinFace() {
  // return which face the mouse is within
  for (int i = 0; i < masterFs.size(); i++) {   ///////////////////////////////////////////////////
    if (i != outerFace) {
      int intersections = 0;
      int startCornerID = masterFs.get(i);
      Corner startCorner = GetCornerFromID(startCornerID);
      int currentCornerID = startCornerID;

      do {
        Corner currentCorner = GetCornerFromID(currentCornerID);
        Vertex currentVertex = GetVertexFromCornerID(currentCornerID);
        Vertex nextVertex = GetVertexFromCornerID(currentCorner.next);

        PVector start = currentVertex.pos;
        PVector end = nextVertex.pos;

        if (HorizontalIntersectsLineSegment(mouseY, start, end)) {
          intersections++;
        }

        currentCornerID = currentCorner.next;
      } while (currentCornerID != startCornerID);

      //println("face " + i + " intersections: " + intersections);

      if (intersections % 2 != 0) {
        return i;
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

public float DrawAreaOfFace(int faceID) {
  float area = 0f;
  PVector center = new PVector(0, 0);
  int numCorners = 0;

  int startCornerID = masterFs.get(faceID);
  Corner startCorner = GetCornerFromID(startCornerID);
  int currentCornerID = startCornerID;

  do {
    Corner currentCorner = GetCornerFromID(currentCornerID);
    Vertex currentVertex = GetVertexFromCornerID(currentCornerID);
    Vertex nextVertex = GetVertexFromCornerID(currentCorner.next);

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
