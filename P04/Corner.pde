public class Corner{
  int id;
  int next, prev, swing, vertex;
  boolean visited;

  public Corner(){
    id = -1;
    visited = false;
    next = -1;
    prev = -1;
    swing = -1;
  }

  public Corner(int cornerID) {
    id = cornerID;
    visited = false;
    next = -1;
    prev = -1;
    swing = -1;
  }

  public Corner(int cornerID, int vertexID) {
    id = cornerID;
    visited = false;
    next = -1;
    prev = -1;
    swing = -1;
    vertex = vertexID;
  }

  public void split(int thisID, Corner end){
    Corner prevC = masterCs.get(prev);
    prevC.next = masterCs.size();
    end.next = thisID;
  }

  public PVector GetDisplayPosition() {
    float d = 30;
    PVector thisPos = GetVertexFromCornerID(id).pos;
    PVector prevPos = GetVertexFromCornerID(prev).pos;
    PVector nextPos = GetVertexFromCornerID(next).pos;
    PVector result = new PVector(thisPos.x,thisPos.y);

    PVector toPrev = new PVector(prevPos.x-thisPos.x, prevPos.y-thisPos.y); // BA
    PVector fromPrev = new PVector(thisPos.x-prevPos.x, thisPos.y-prevPos.y); // AB
    PVector toNext = new PVector(nextPos.x-thisPos.x, nextPos.y-thisPos.y); // BC

    toPrev.normalize();
    fromPrev.normalize();
    toNext.normalize();

    // s.magnitude = d / (toPrev . toNext)
    PVector divisionTemp = new PVector(toPrev.x, toPrev.y);
    float divResult = divisionTemp.dot(toNext);
    float s = d;//abs(d / divResult);

    toPrev.add(toNext);
    toPrev.normalize();
    if (det(fromPrev, toNext) > 0) {
      // clockwise, inside of face
      toPrev.mult(s);
    } else {
      // counter-clockwise, outside of face
      toPrev.mult(-s);
    }

    result.add(toPrev);

    return result;
  }

  public Corner FindUnswing(){
    Corner currCorner = this;
    while(currCorner.swing != id){
      currCorner = GetCornerFromID(currCorner.swing);
    }

    return currCorner;
  }

  public boolean isHovered() {
    boolean result = mouseIsWithinCircle(this.GetDisplayPosition(), cornerRadius);
    return result;
  }

  public void isInteracted() {
    if (this.isHovered()) {
      this.DrawInformation();
    }
  }

  public void Draw() {
    fill(cornerColor);
    stroke(cornerColor);

    Corner tmp = masterCs.get(id);
    // println("corner " + id + " has next: " + tmp.next + " and prev: " + tmp.prev);
    // println("stored next " + next + "stored prev: " + prev);
    PVector pos = GetDisplayPosition();
    showDisk(pos.x, pos.y, 2); 
  }

  public void DrawInformation() {
    // draw vertex information
    fill(cornerColor);
    textSize(20);
    text(this.id, mouseX + vertexTextOffset.x, mouseY + vertexTextOffset.y);
  }
}