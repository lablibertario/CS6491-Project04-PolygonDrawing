public class Corner{
  int id;
  int next, prev, swing, vertex;
  boolean visited;
  PVector displayPos;

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

  public void kill(ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs) {
    if (this.swing != -1) {
      Corner unswing = FindUnswing(_masterCs);
      unswing.swing = this.swing;
    }
    GetVertexFromID(this.vertex, _masterVs).RemoveCorner(this.id);

    id = -1;
    next = -1;
    prev = -1;
    swing = -1;
    vertex = -1;
  }

  public boolean exists() {
    return (id > -1);
  }

  public PVector GetDisplayPosition(ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs, boolean extruding) {
    float d = 30;
    PVector thisPos = GetVertexFromCornerID(id, _masterVs, _masterCs).pos;
    PVector prevPos = GetVertexFromCornerID(prev, _masterVs, _masterCs).pos;
    PVector nextPos = GetVertexFromCornerID(next, _masterVs,_masterCs).pos;
    PVector result = new PVector(thisPos.x,thisPos.y, thisPos.z);

    PVector toPrev = new PVector(prevPos.x-thisPos.x, prevPos.y-thisPos.y, prevPos.z-thisPos.z); // BA
    PVector fromPrev = new PVector(thisPos.x-prevPos.x, thisPos.y-prevPos.y, thisPos.z-prevPos.z); // AB
    PVector toNext = new PVector(nextPos.x-thisPos.x, nextPos.y-thisPos.y, nextPos.z-thisPos.z); // BC

    toPrev.normalize();
    fromPrev.normalize();
    toNext.normalize();

    // s.magnitude = d / (toPrev . toNext)
    PVector divisionTemp = new PVector(toPrev.x, toPrev.y, toPrev.z);
    float divResult = divisionTemp.dot(toNext);
    float s = d;//abs(d / divResult);

    toPrev.add(toNext);
    toPrev.normalize();

    if(extruding) {
      if (det3D(fromPrev, toNext) > 0) {
        // clockwise, inside of face
        toPrev.mult(s);
      } else {
        // counter-clockwise, outside of face
        toPrev.mult(-s);
      }
    } else {
      if (det(fromPrev, toNext) > 0) {
      // clockwise, inside of face
        toPrev.mult(s);
      } else {
        // counter-clockwise, outside of face
        toPrev.mult(-s);
      }
    }

    result.add(toPrev);

    return result;
  }

  public Corner FindUnswing(ArrayList<Corner> _masterCs){
    Corner currCorner = this;
    while(currCorner.swing != id){
      //println("swing id: " + currCorner.swing);
      currCorner = GetCornerFromID(currCorner.swing, _masterCs);
    }

    return currCorner;
  }

  public boolean isHovered(ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs) {
    boolean result = mouseIsWithinCircle(this.GetDisplayPosition(_masterVs, _masterCs, false), cornerRadius);
    return result;
  }

  public boolean isInteracted(ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs) {
    if (this.isHovered(_masterVs, _masterCs)) {
      this.DrawInformation();
      return true;
    }
    return false;
  }

  public void Draw(color fillColor, ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs, int _nextRedraw, int _prevRedraw, int _swingRedraw) {
    fill(fillColor);
    stroke(fillColor);

    Corner tmp = _masterCs.get(id);
    // println("corner " + id + " has next: " + tmp.next + " and prev: " + tmp.prev);
    // println("stored next " + next + "stored prev: " + prev);
    displayPos = GetDisplayPosition(_masterVs, _masterCs, true);
    showDisk(displayPos.x, displayPos.y, displayPos.z, 2, true); 

    DrawInformation();

    if(isHovered(_masterVs, _masterCs)) {
      _swingRedraw = swing;
      _nextRedraw = next;
      _prevRedraw = prev;
    }
  }

  public void DrawInformation() {
    // draw vertex information
    //println("corner number: "+this.id);
    fill(nextColor);
    textSize(20);
    text(this.id, displayPos.x - vertexTextOffset.x, displayPos.y + vertexTextOffset.y, displayPos.z + vertexTextOffset.z);
  }
}