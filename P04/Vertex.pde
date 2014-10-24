public class Vertex{
 PVector pos;
 int id;
 public ArrayList<Integer> corners = new ArrayList<Integer>();
 
  public Vertex(){

  }

  public Vertex(int _x, int _y) {
    pos = new PVector(_x, _y);
  }

  public Vertex(int _x, int _y, int vertexID) {
    pos = new PVector(_x, _y);
    id = vertexID;
  }
 
  public void AddCorner(int cornerID) {
    corners.add(cornerID);
  }

  public boolean exists() {
    return (id > -1);
  }

  // public void RemoveCorner(int cornerID) {
  //   Corner startCorner = GetCornerFromID(corners.get(0));
  //   Corner removedCorner = GetCornerFromID(cornerID);
  //   Corner currentCorner = startCorner;
  //   println("corner " + cornerID + " removal from " + corners);
  //   do {
  //     println("this -> swing: " + currentCorner.id + " -> " + currentCorner.swing);
  //     if (currentCorner.swing == cornerID) {
  //       currentCorner.swing = removedCorner.swing;
  //       corners.remove(FindCornerIndex(cornerID));
  //       println("this -> newSwing: " + currentCorner.id + " -> " + currentCorner.swing);
  //       break;
  //     }
  //     currentCorner = GetCornerFromID(currentCorner.swing);
  //   }
  //   while (currentCorner != startCorner);
  // }

  public void RemoveCorner(int cornerID) {
    int index = FindCornerIndex(cornerID);
    if (index != -1) {
      corners.remove(index);
    }
  }

  private int FindCornerIndex(int cornerID) {
    for (int i = 0; i < corners.size(); i++) {
      if (corners.get(i) == cornerID) {
        return i;
      }
    }
    return -1;
  }

  public boolean isHovered() {
    boolean result = mouseIsWithinCircle(this.pos, vertexRadius);
    return result;
  }

  public boolean isClicked() {
    boolean result = (this.isHovered() && mousePressed);
    return result;
  }

//   ***********insert on edge values********
// prevCorner: 1
// nextCorner: 3
// swingCorner: 9
// swingPrev: 4
// ***********insert on edge values********

  public boolean isDragged() {
    boolean result = (this.isSelected() && mouseDragged); 
    return result;
  }

  public boolean isSelected() {
    boolean result = (selectedVertexID == this.id);
    return result;
  }

  public void isInteracted(ArrayList<Vertex> _masterVs, ArrayList<Corner> _masterCs) {
    if (this.isHovered()) {
      this.DrawInformation();
    }

    if (this.isClicked()) {
      this.DrawInformation();
      selectedVertexID = this.id;
      if(editMode) {
        editStart = true;
      }
    }

    if (this.isDragged()) {
      //drag in new vert/edge
      if(editMode){
        if(editStart){
          boolean added = vertexHandler.AddVertex(mouseX, mouseY, id, _masterVs, _masterCs);
          //rubberBand = GetVertexFromID(masterVs.size()-1);
          if(added){
            println("added a vert");
            editStart = false;
            editMode = false;
            selectedVertexID = masterVs.size()-1;
          }
        }
      } else {
        this.DrawInformation();
        this.Drag();
      }
    }
  }

  public void Drag() {
    // move vertex with mouse
    this.pos = new PVector(mouseX, mouseY);
    selectedVertexID = this.id;
  }

  public void Draw() {
    // draw the vertex itself
    stroke(vertexColor);
    noFill();

    showDisk(pos.x, pos.y, vertexRadius);
  }

  public void DrawInformation() {
    // draw vertex information
    fill(vertexColor);
    textSize(20);
    text(this.id, mouseX + vertexTextOffset.x, mouseY + vertexTextOffset.y);
  }
}
