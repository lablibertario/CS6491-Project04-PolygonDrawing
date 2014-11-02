// LecturesInGraphics: utilities
// Colors, pictures, text formatting
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012


///////////////
//left to do:
//smooth corners
//extrusion walls
//    draw walls
//insert new corners w/ extrusion
//    make sure corners displaying in correct place
//fix 3d pick
//
//3d coversion breaks when inserting vert?
//change the bridge of two face edges to be a straight line (nearest pt has potential
//  trouble of going outside shape)
////////////////

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

int vertexRadius = 5;
color vertexColor = black;
PVector vertexTextOffset = new PVector(7, -15);

int cornerRadius = 6;
color cornerColor = black;
color swingColor = color(213, 162, 222);
color nextColor = color(255, 168, 138);
color prevColor = color(100, 185, 144);
PVector cornerTextOffset = new PVector(7, -15);

int areaTextSize = 30;
color areaColor = blue;

int extrusionHeight = 50;

// ************************************************************************ GRAPHICS 
void pen(color c, float w) {
  stroke(c); 
  strokeWeight(w);
}
void showDisk(float x, float y, float z, float r, boolean showStroke) {
  if(in3D) {
    pushMatrix();
    translate(x, y, z);
    //if(!showStroke) noStroke();
    //fill(255);
    sphere(r*2);
    popMatrix();
    //println("sphere at x, y, z: "+x  +", "+ y +", "+ z);
  }
  else ellipse(x, y, r*2, r*2);
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

  translate(loc.x, loc.y, loc.z);
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
      if(in3D) {
      pushMatrix();
      //translate(start.x, start.y, start.z);
      //noFill();
      stroke(sidewalkColor);
      beginShape(LINES);
      vertex(start.x, start.y, start.z);
      vertex(end.x, end.y, end.z);
      endShape();
      popMatrix();
    } else {
      DrawLine(start, end, sidewalkThickness, sidewalkColor);
    }
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

  if(in3D) {
    pushMatrix();
    //translate(start.x, start.y, start.z);
    //noFill();
    stroke(edgeColor);
    beginShape(LINES);
    vertex(start.x, start.y, start.z);
    vertex(end.x, end.y, end.z);
    endShape();
    popMatrix();
  } else {
    DrawLine(start, end, edgeThickness, edgeColor);
  }

  if (mouseIsWithinRectangle(startV.pos, endV.pos, edgeThickness*2)) {
    // Handle mouse hovering over edge
    fill(edgeColor);
    textSize(20);
   // pt mousepos;
   // mousepos = pick(mouseX, mouseY);
    PVector closestPoint = GetClosestPointOnEdge(new PVector(mouseX, mouseY), startV.pos, endV.pos);
    showDisk(closestPoint.x, closestPoint.y, closestPoint.z, edgeThickness*2, true);

    if(addVert && mouseClicked) {
      //println("add vert");
      vertexHandler.InsertVerteXInEdge(mouseX, mouseY, startV.id, endV.id, _mastVs, _mastCs, _mastFs);
    }
    //text(GetDistanceFromEdge(new PVector(mouseX, mouseY), startV.pos, endV.pos), mouseX + edgeTextOffset.x, mouseY + edgeTextOffset.y);
  }
}

public boolean mouseIsWithinCircle(PVector pos, float radius) {
  pt mousepos;
  mousepos = pick(mouseX, mouseY);
  PVector mousePos = new PVector(mousepos.x, mousepos.y, mousepos.z);
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

  //set up geo3D objects
  Geo3D geo3DObject = new Geo3D();
  Geo3D geo3DTopObject = new Geo3D();
  ArrayList<Corner> _geoCs = new ArrayList<Corner>();
  ArrayList<Vertex> _geoVs = new ArrayList<Vertex>();
  ArrayList<Integer> _geoFs = new ArrayList<Integer>();
  //store top face values
  ArrayList<Corner> _topCs = new ArrayList<Corner>();
  ArrayList<Vertex> _topVs = new ArrayList<Vertex>();
  ArrayList<Integer> _topFs = new ArrayList<Integer>();

  int connectVert = -1;
  for (int i = 0; i < masterFs.size(); i++) {
    //walk through the existing faces from the master(graph) arrays
    Corner startC = GetCornerFromFaceID(i, masterCs, masterFs);
    Corner currentC = startC;
    //get position of start corner
    PVector cPos = startC.GetDisplayPosition(masterVs, masterCs);
    //assign startC to a new vertex
    vertexHandler.AddVertex((int)cPos.x, (int)cPos.y, 0, connectVert, _geoVs, _geoCs, _geoFs);
    connectVert++;
    //NEED TO SWITCH BELOW CONNECTVERT TO BE THE VERT IMMEDIATELY BELOW
    vertexHandler.AddVertex((int)cPos.x, (int)cPos.y, extrusionHeight, _geoVs.size()-1, _geoVs, _geoCs, _geoFs);

    int connectPos;
    println("_geoVs.size(): "+_geoVs.size());
    //NEED TO CHANGE THIS TO THE COMMENTED LINE ONCE SECOND SET OF VERTS ADDING
    if(_geoVs.size() > 0) connectPos = _geoVs.size()-1;
    else connectPos = 0;
    //println("_geoVs.size()/2 -1: "+(_geoVs.size()/2 -1));
    //connectPos = _geoVs.size()/2 -1;

    do {
        Corner nextC = GetCornerFromID(currentC.next, masterCs);
        PVector cNextPos = nextC.GetDisplayPosition(masterVs, masterCs);
        println("cNextPos: "+cNextPos);
        //assign startC to a new vertex
        vertexHandler.AddVertex((int)cNextPos.x, (int)cNextPos.y, 0, connectPos, _geoVs, _geoCs, _geoFs);
      //  vertexHandler.AddVertex((int)cNextPos.x, (int)cNextPos.y, extrusionHeight, connectPos, _geoVs, _geoCs, _geoFs);
        //assign each next to a new vertex
        currentC = nextC;
        connectPos++;
    } while (currentC.id != startC.id && currentC.next != -1);

    if(i+1 < masterFs.size()) connectVert = determineNearestVert(i, _geoVs);
  }

  //assign our determined arrays to the faces3D Array
  geo3DObject.geoCs = _geoCs;
  geo3DObject.geoVs = _geoVs;
  geo3DObject.geoFs = _geoFs;

  //offset top verts in z
  /*for(Vertex v : _topVs){
    v.pos.z += 50;
    v.pos.y += 50;
  }

  geo3DTopObject.geoCs = _topCs;
  geo3DTopObject.geoVs = _topVs;
  geo3DTopObject.geoFs = _topFs;
  geo3DTopObject.planeBelongsTo = 1;*/

 // println("geo3DTopObject.geoFs: "+geo3DTopObject.geoFs);
 //add the top object geo to the same object as the bottom one

  faces3D.add(geo3DObject);
  //faces3D.add(geo3DTopObject);

  //ConnectBottomToTop();

  //ConnectAllSidewalks();
  //recalculate faces

  //handle drawing of these in p04
}

int determineNearestVert(int i, ArrayList<Vertex> geoVs) {
  int nearestVertIndex = 0;

  //take the first vert of the next sidewal/geo set
  Corner startC = GetCornerFromFaceID(i, masterCs, masterFs);
  Corner currentC = startC;
  PVector cPos = startC.GetDisplayPosition(masterVs, masterCs);

  //figure out which of the previous set is closest to this point
  float shortestDist = 9001f;
  for (int j = 0; j < geoVs.size(); j++){
    Vertex v = (Vertex)geoVs.get(j);
    PVector vPos = new PVector(v.pos.x, v.pos.y, v.pos.z);
    float distFromNextPt = PVector.dist(cPos, vPos);
    if(distFromNextPt < shortestDist) {
      shortestDist = distFromNextPt;
      nearestVertIndex = j;
    }
  }

  //println("closest to vert: "+nearestVertIndex);

  return nearestVertIndex;
}

void showWalls(){
  Geo3D topBottom = (Geo3D)faces3D.get(0);
  int half = topBottom.geoVs.size()/2;

  for(int i = 0; i < half-2; i++){
    //need to do this for faces instead (sidewalks)
    /*PVector v1Pos = GetVertexFromID(i, topBottom.geoVs).pos;
    PVector v2Pos = GetVertexFromID(i+1, topBottom.geoVs).pos;
    PVector v3Pos = GetVertexFromID(half+i, topBottom.geoVs).pos;
    PVector v4Pos = GetVertexFromID(half+i+1, topBottom.geoVs).pos;

    beginShape(); 
    vertex(v1Pos.x, v1Pos.y, v1Pos.z);
    vertex(v2Pos.x, v2Pos.y, v2Pos.z);
    vertex(v3Pos.x, v3Pos.y, v3Pos.z);
    vertex(v4Pos.x, v4Pos.y, v4Pos.z);
    endShape(CLOSE);*/
  }
}

void ConnectBottomToTop(){
  Geo3D topObject = (Geo3D)faces3D.get(0);
  Geo3D bottomObject = (Geo3D)faces3D.get(1);
  int half = topObject.geoVs.size();///2;

  //add in bottom object verts to top obj geo


  //connect the like points
  for(int i = 0; i < half; i++){
    Vertex startV = GetVertexFromID(i, topObject.geoVs);
    Vertex endV = GetVertexFromID(i+1, topObject.geoVs);
    println("connecting: "+ startV.id + " to " + endV.id);
    println("startV.pos: "+startV.pos);
    println("endV.pos: "+endV.pos);

    //vertexHandler.AddVertex((int)startV.pos.x, (int)startV.pos.y, endV.id, topObject.geoVs, topObject.geoCs, topObject.geoFs);
  }

  //remove bottom Object from faces array
  faces3D.remove(1);
}

//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture
