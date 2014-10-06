public class Vertex{
 PVector pos;
 int id;
 public ArrayList<Integer> corners = new ArrayList<Integer>();

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

  public boolean MouseOver() {
    return mouseIsWithinCircle(this.pos, vertexRadius);
  }

  public boolean MouseClicked() {
    return (this.MouseOver() && mouseClick);
  }

  public boolean MouseDragging() {
    boolean result = (this.MouseClicked() && mouseDrag); 
    if (result) {
      this.pos = new PVector(mouseX, mouseY);
    }
    return result;
  }

  public void Draw() {
    stroke(vertexColor);
    noFill();

    showDisk(pos.x, pos.y, vertexRadius);
  }
}
