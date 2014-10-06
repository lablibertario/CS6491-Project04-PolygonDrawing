// LecturesInGraphics: utilities
// Colors, pictures, text formatting
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;

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
PImage power;
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
    if (mouseIsWithinCircle(v.pos, 10)) {
      fill(black);
      textSize(20);
      text(v.id, mouseX+7, mouseY-15);
    }
    v.Draw();
  }
  textSize(12);
}

void displayCorners() {
  for (int i = 0; i < masterCs.size(); i++) {
    Corner c = masterCs.get(i);
    if (mouseIsWithinCircle(c.GetDisplayPosition(), 4)) {
      fill(red);
      textSize(20);
      text(c.id, mouseX+7, mouseY-15);
    }
    c.Draw();
  }
  textSize(12);
}

void displayEdges() {
  for (int i = 0; i < masterCs.size(); i++) {
    Corner c = masterCs.get(i);
    Vertex startV = GetVertexFromCornerID(c.id);
    Vertex endV = GetVertexFromCornerID(c.next);
    DrawLine(startV.pos, endV.pos, 2, blue);
    DrawSidewalk(GetCornerFromID(c.id), GetCornerFromID(c.next));
  }
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

  DrawLine(start, end, 1, green);
}

public boolean mouseIsWithinCircle(PVector pos, float radius) {
  PVector mousePos = new PVector(mouseX, mouseY);
  return (mousePos.dist(pos) <= radius);
}


//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture

