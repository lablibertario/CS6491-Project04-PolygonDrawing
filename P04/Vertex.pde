public class Vertex{
 PVector pos;
 int id;
 boolean editStart = true;
 Vertex rubberBand = new Vertex();
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

  public boolean isHovered() {
    boolean result = mouseIsWithinCircle(this.pos, vertexRadius);
    return result;
  }

  public boolean isClicked() {
    boolean result = (this.isHovered() && mousePressed);
    return result;
  }

  public boolean isDragged() {
    boolean result = (this.isSelected() && mouseDragged); 
    return result;
  }

  public boolean isSelected() {
    editStart = true;
    boolean result = (selectedVertexID == this.id);
    return result;
  }

  public void isInteracted() {
    if (this.isHovered()) {
      this.DrawInformation();
    }

    if (this.isClicked()) {
      this.DrawInformation();
      selectedVertexID = this.id;
    }

    if (this.isDragged()) {
      //drag in new vert/edge
      if(editMode){
        if(editStart){
          vertexHandler.AddVertex((int)pos.x, (int)pos.y, id);
          rubberBand = GetVertexFromID(masterVs.size()-1);
          editStart = false;
        } else {
          rubberBand.DrawInformation();
          rubberBand.Drag();
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
