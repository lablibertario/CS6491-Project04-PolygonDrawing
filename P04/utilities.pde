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
color cornerColor = red;
PVector cornerTextOffset = new PVector(7, -15);

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
  float heading = a.heading() + PI;
  // if (heading < 0)
  //  heading += 2*PI;
  return heading;
}

// ************************************************************************ IMAGES & VIDEO 
int pictureCounter=0;
PImage myFace, myFace2; // picture of author's face, should be: data/pic.jpg in sketch folder
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
  image(myFace2, (width-myFace.width), 25, myFace.width/2, myFace.height/2);
}
void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

void displayVertices() {
  for (int i = 0; i < masterVs.size(); i++) {
    Vertex v = masterVs.get(i);
    v.Draw();
  }
  textSize(12);
}

void displayCorners() {
  for (int i = 0; i < masterCs.size(); i++) {
    Corner c = masterCs.get(i);
    c.Draw();
  }
  textSize(12);
}

void displayEdges() {
  for (int i = 0; i < masterCs.size(); i++) {
    Corner startC = masterCs.get(i);
    Corner endC = GetCornerFromID(startC.next);

    //DrawSidewalk(startC, endC);

    Vertex startV = GetVertexFromCornerID(startC.id);
    Vertex endV = GetVertexFromCornerID(endC.id);

    DrawEdge(startV, endV);
  }
}

void displayFaceSidewalks() {
  for (int i = 0; i < masterFs.size(); i++) {
    DrawFaceSidewalks(masterFs.get(i));
  }
}

void DrawFaceSidewalks(int faceID) {
  Corner startC = GetCornerFromFaceID(faceID);
  Corner currentC = startC;
  do {
      Corner nextC = GetCornerFromID(currentC.next);
      DrawSidewalk(currentC, nextC);
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

void DrawSidewalk(Corner startC, Corner endC) {
  PVector start = startC.GetDisplayPosition();
  PVector end = endC.GetDisplayPosition();

  DrawLine(start, end, sidewalkThickness, sidewalkColor);
}

void DrawEdge(Vertex startV, Vertex endV) {
  PVector start = startV.pos;
  PVector end = endV.pos;

  DrawLine(start, end, edgeThickness, edgeColor);

  if (mouseIsWithinRectangle(startV.pos, endV.pos, edgeThickness*2)) {
    // Handle mouse hovering over edge
    fill(edgeColor);
    textSize(20);
    PVector closestPoint = GetClosestPointOnEdge(new PVector(mouseX, mouseY), startV.pos, endV.pos);
    showDisk(closestPoint.x, closestPoint.y, edgeThickness*2);
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

//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture

