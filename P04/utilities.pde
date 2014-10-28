// LecturesInGraphics: utilities
// Colors, pictures, text formatting
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;

int edgeThickness = 2;
color edgeColor = blue;
PVector edgeTextOffset = new PVector(7, -15);
//int edgePointRadius = 4;

int sidewalkThickness = 1;
color sidewalkColor = green;
PVector sidewalkTextOffset;

int vertexRadius = 10;
color vertexColor = black;
PVector vertexTextOffset = new PVector(7, -15);

int cornerRadius = 3;
color cornerColor = black;
color swingColor = color(213, 162, 222);
color nextColor = color(255, 168, 138);
color prevColor = color(100, 185, 144);
PVector cornerTextOffset = new PVector(7, -15);

int areaTextSize = 30;
color areaColor = blue;

// ************************************************************************ GRAPHICS 
void pen(color c, float w) {
  stroke(c); 
  strokeWeight(w);
}
void showDisk(float x, float y, float r) {
  ellipse(x, y, r*2, r*2);
}

float det(PVector a, PVector b) { //may be a terrible terrible thing
  PVector aRot = new PVector(-a.y, a.x);
  return aRot.dot(b);
}

boolean isToRightOf(PVector a, PVector b){
  float check = det(a, b);
  return check > 0;
}

public float GetAngle(PVector tempa, PVector tempb) {
  // returns clockwise angle from a to b
  PVector a = new PVector(tempa.x, tempa.y);
  PVector b = new PVector(tempb.x, tempb.y);

  float det = det(a, b);
  float dot = a.dot(b);
  float alpha = atan2(det, dot);

  if (alpha < 0) {
    alpha += 2*PI;
  }

  return alpha;
}

public float GetPosAngle(PVector a) {
  float heading = a.heading();// + PI;
  if (heading < 0)
   heading += 2*PI;
  return heading;
}

// ************************************************************************ IMAGES & VIDEO 
int pictureCounter=0;
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
void snapPicture() {
  saveFrame("PICTURES/P"+nf(pictureCounter++, 3)+".jpg");
}

// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {
  fill(0); 
  text(S, x, y); 
  noFill();
} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) {
  fill(0); 
  text(S, 10, 20+i*20); 
  noFill();
} // writes black at line i
void scribeHeaderRight(String S) {
  fill(0); 
  text(S, width-7.5*S.length(), 20); 
  noFill();
} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {
  fill(0); 
  text(S, 10, height-10-i*20); 
  noFill();
} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {
  fill(0); 
  text(S, mouseX, mouseY);
  noFill();
} // writes on screen near mouse
void scribeMouseCoordinates() {
  fill(black); 
  text("("+mouseX+","+mouseY+")", mouseX+7, mouseY+25); 
  noFill();
}
void displayHeader() { // Displays title and authors face on screen
  scribeHeader(title, 0); 
  scribeHeaderRight(name); 
  image(myFace, width-myFace.width/2, 25, myFace.width/2, myFace.height/2); 
}
void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

void displayVertices(ArrayList<Vertex> _mastVs) {
  //println("draw vertices");
  for (int i = 0; i < _mastVs.size(); i++) {
    Vertex v = _mastVs.get(i);
    ////println("drawing v " + v.id);
    if (v.exists()) {
      v.Draw();
    }
  }
  textSize(12);
}

void displayCorners(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, int _nextRedraw, int _prevRedraw, int _swingRedraw) {
  //println("draw corners");
  for (int i = 0; i < _mastCs.size(); i++) {
    Corner c = _mastCs.get(i);
    if (c.exists()) {
      // //println("draw corner " + c.id);
      c.Draw(cornerColor, _mastVs, _mastCs, _nextRedraw, _prevRedraw, _swingRedraw);
    }
  }
  textSize(12);
}

void displayEdges(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  //println("draw edges");
  for (int i = 0; i < _mastCs.size(); i++) {
    Corner startC = _mastCs.get(i);

    if (startC.next != -1) {
      Corner endC = GetCornerFromID(startC.next, _mastCs);

      if (startC.exists() && endC.exists()) {
        Vertex startV = GetVertexFromCornerID(startC.id, _mastVs, _mastCs);
        Vertex endV = GetVertexFromCornerID(endC.id, _mastVs, _mastCs);

        DrawEdge(startV, endV, _mastVs, _mastCs, _mastFs);
      }
    }
  }
}

void displayFaceSidewalks(ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  for (int i = 0; i < _mastFs.size(); i++) {
    DrawFaceSidewalks(i, _mastVs, _mastCs, _mastFs);
  }
}

void DrawFaceSidewalks(int faceID, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  //println("draw face " + faceID + " sidewalks");
  Corner startC = GetCornerFromFaceID(faceID, _mastCs, _mastFs);
  Corner currentC = startC;
  do {
      Corner nextC = GetCornerFromID(currentC.next, _mastCs);
      DrawSidewalk(currentC, nextC, _mastVs, _mastCs);
      currentC = nextC;
  } while (currentC.id != startC.id && currentC.next != -1);
}

void DrawLine(PVector start, PVector end, float thickness, color rgb) {
  PVector between = new PVector(end.x - start.x, end.y - start.y);
  float rot = between.heading();
  PVector loc = new PVector((end.x + start.x)/2, (end.y + start.y)/2);

  pushMatrix();
  
  fill(rgb);
  stroke(rgb);

  translate(loc.x, loc.y);
  rotate(rot);
  rectMode(CENTER);

  rect(0f, 0f, start.dist(end), thickness);

  popMatrix();
}

void DrawSidewalk(Corner startC, Corner endC, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs) {
  PVector start = startC.GetDisplayPosition(_mastVs, _mastCs);
  PVector end = endC.GetDisplayPosition(_mastVs, _mastCs);

  ////println("sidewalk: " + startC.vertex + " -> " + endC.vertex);

  //if the sidewalk is on the outside and comes to a really sharp point,
  //smooth it out
  //part 1: determine when this happens
  int smoothness = DetermineSmoothness(startC, endC);
  if(smoothness == 0 ) {
    DrawLine(start, end, sidewalkThickness, sidewalkColor);
  } else {
    //part 2: smooth along sphere via line segments

  }
}

int DetermineSmoothness(Corner c1, Corner c2) {

  return 0;
}

void DrawEdge(Vertex startV, Vertex endV, ArrayList<Vertex> _mastVs, ArrayList<Corner> _mastCs, ArrayList<Integer> _mastFs) {
  PVector start = startV.pos;
  PVector end = endV.pos;

  DrawLine(start, end, edgeThickness, edgeColor);

  if (mouseIsWithinRectangle(startV.pos, endV.pos, edgeThickness*2)) {
    // Handle mouse hovering over edge
    fill(edgeColor);
    textSize(20);
    PVector closestPoint = GetClosestPointOnEdge(new PVector(mouseX, mouseY), startV.pos, endV.pos);
    showDisk(closestPoint.x, closestPoint.y, edgeThickness*2);

    if(addVert && mouseClicked) {
      //println("add vert");
      vertexHandler.InsertVerteXInEdge(mouseX, mouseY, startV.id, endV.id, _mastVs, _mastCs, _mastFs);
    }
    //text(GetDistanceFromEdge(new PVector(mouseX, mouseY), startV.pos, endV.pos), mouseX + edgeTextOffset.x, mouseY + edgeTextOffset.y);
  }
}

public boolean mouseIsWithinCircle(PVector pos, float radius) {
  PVector mousePos = new PVector(mouseX, mouseY);
  return (mousePos.dist(pos) <= radius);
}

public boolean mouseIsWithinRectangle(PVector start, PVector end, int thickness) {
  PVector mousePos = new PVector(mouseX, mouseY);
  float distance = abs(GetDistanceFromEdge(mousePos, start, end));
  return (distance <= thickness);
}

public float GetSlopeOfEdge(PVector start, PVector end) {
  return (end.y-start.y) / (end.x-start.x);
}

public float sqr(float x) { return x * x; }

// c = point, ab = edge
public float GetDistanceFromEdge(PVector _c, PVector _a, PVector _b) {
  float result;
  PVector a = new PVector(_a.x, _a.y);
  PVector b = new PVector(_b.x, _b.y);
  PVector c = new PVector(_c.x, _c.y);

  // exclude part of line segment that overlaps with vertex radius
  PVector atob = new PVector(b.x - a.x, b.y - a.y);
  atob.normalize();
  atob.mult(vertexRadius * 3f);
  a.add(atob);
  b.sub(atob);

  PVector ab = new PVector(b.x - a.x, b.y - a.y);
  PVector bc = new PVector(c.x - b.x, c.y - b.y);
  PVector ba = new PVector(a.x - b.x, a.y - b.y);
  PVector ac = new PVector(c.x - a.x, c.y - a.y);

  if (ab.dot(bc) > 0) {
    result = b.dist(c);
  } else if (ba.dot(ac) > 0) {
    result = a.dist(c);
  } else {
    result = (ab.x * ac.y - ab.y * ac.x) / a.dist(b);
  }

  return result;
}

public PVector GetClosestPointOnEdge(PVector c, PVector a, PVector b) {
  PVector v = new PVector(b.y - a.y, a.x - b.x);
  v.normalize();

  float d = GetDistanceFromEdge(c, a, b);
  v.mult(d);

  PVector result = new PVector(c.x, c.y);
  result.add(v);

  return result;
}

public void CalculateSidewalkGeo() {
  //cycle through each face and generate the geometry that goes with it
  faces3D = new ArrayList<Geo3D>();
  println("------------------------------: ");
  println("masterFs: "+masterFs);
  for (int i = 0; i < masterFs.size(); i++) {
    //set up geo3D objects
    Geo3D geo3DObject = new Geo3D();
    ArrayList<Corner> _geoCs = new ArrayList<Corner>();
    ArrayList<Vertex> _geoVs = new ArrayList<Vertex>();
    ArrayList<Integer> _geoFs = new ArrayList<Integer>();
    //walk through the existing faces from the master(graph) arrays
    Corner startC = GetCornerFromFaceID(i, masterCs, masterFs);
    Corner currentC = startC;
    //get position of start corner
    PVector cPos = startC.GetDisplayPosition(masterVs, masterCs);
    //assign startC to a new vertex
    vertexHandler.AddVertex((int)cPos.x, (int)cPos.y, -1, _geoVs, _geoCs, _geoFs);

    int connectPos = 0;
    do {
        Corner nextC = GetCornerFromID(currentC.next, masterCs);
        PVector cNextPos = nextC.GetDisplayPosition(masterVs, masterCs);
        //assign startC to a new vertex
        vertexHandler.AddVertex((int)cNextPos.x, (int)cNextPos.y, connectPos, _geoVs, _geoCs, _geoFs);
        //assign each next to a new vertex
        currentC = nextC;
        connectPos++;
    } while (currentC.id != startC.id && currentC.next != -1);

    //assign our determined arrays to the faces3D Array
    geo3DObject.geoCs = _geoCs;
    geo3DObject.geoVs = _geoVs;
    geo3DObject.geoFs = _geoFs;

    println("geo3DObject.geoFs: "+geo3DObject.geoFs);

    faces3D.add(geo3DObject);
  }

  //handle drawing of these in p04
}

//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture
