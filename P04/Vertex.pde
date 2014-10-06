public class Vertex{
 PVector pos;
 int id;
 public ArrayList<Integer> corners = new ArrayList<Integer>();
 
//  public Vertex(int _x, int _y, int connectIndex){
//    Vertex connectTo = null;
//    if(connectIndex != -1) {
//      println("we're connected");
//      connectTo = masterVs.get(connectIndex);
//    }
//    pos = new PVector(_x, _y);
//    Vertex prevV = null;
//    if(masterVs.size() >= 1){
//       Corner thisNew = new Corner();
//       Corner prevNew = new Corner();
//       if(connectTo != null) {
//         prevNew.vertex = connectIndex;
//       } else {
//         prevNew.vertex = 0;
//       }
//       thisNew.vertex = masterVs.size();
      
      
//      //special case of second vertex
//      if(masterVs.size() == 1){
//         prevV = masterVs.get(0);
//         prevNew.next = 1;
//         thisNew.next = 0;
//         prevNew.prev = 1;
//         thisNew.prev = 0;
//         //THIS LINE IS TEMP
//         //REMOVE THIS LINE
//         //thisNew.swing = 2;
//         //THAT ONE
        
//         masterCs.add(prevNew);
//         masterCs.add(thisNew);
        
//         prevV.corners.append((masterCs.size()-2));
//         corners.append((masterCs.size()-1));
        
//      } //adding additional vertices
//      else if ( masterVs.size() > 1 ){        
//        prevV = GetVertex(masterVs.size()-1);        
//        //if this is getting added between two lines, do det product with new line and all existing
//        //  lines out of this point until it's to the right of one and the other is to the right of it
//        //  (it's between the lines)
//        //  then consider the starting corner of the one to the right of this as our new prev and reassign
//        //if there's only one edge other than this one coming out of this point(only one previously existing
//        //  corner) we're replacing the previously existing guy. IF the new line is to the right of the existing
//        //  one, then we're replacing the end corner, otherwise, these just get tacked on to the cycle
       
// //TEMPTEMPTEMTP
//        //our new vector
//        PVector newLine = new PVector(pos.x - connectTo.pos.x, pos.y - connectTo.pos.y);
//        //for every corner(/line) that extends from the vertex we're connecting to
//        for(int i = 0; i < connectTo.corners.size(); i++){
//          //grab all the line ends
//          int cornerEndIndex = connectTo.corners.get(i);
//          Corner cNext = masterCs.get((masterCs.get(cornerEndIndex)).next);
//          int cEVID = cNext.vertex;
//          Vertex cornerEnd = masterVs.get(cEVID);
//          int cornerSwingIndex = connectTo.corners.get(i);
//          println("grabbing " + cornerSwingIndex);
//          int swingCheck = (masterCs.get(cornerSwingIndex)).swing;
//          PVector lineCheck = new PVector(cornerEnd.pos.x - connectTo.pos.x, cornerEnd.pos.y - connectTo.pos.y);
//          if(swingCheck != -1) {
//            //if a swing exists, there's more than one line and we should check if our new line is between them
//            int nextCornerIndex = connectTo.corners.get(i);
//            int nCESwingID = (masterCs.get(nextCornerIndex)).swing;
//            Corner swingCorner = (masterCs.get(nCESwingID));
//            Vertex nextCornerEnd = masterVs.get(swingCorner.vertex);
//            PVector lineCheck2 = new PVector(nextCornerEnd.pos.x - connectTo.pos.x, nextCornerEnd.pos.y - connectTo.pos.y);
           
//            float check1 = det(lineCheck, newLine);
//            float check2 = det(lineCheck2, newLine);
//            //see if our new edge is between these previous two
//            if( check1 > 0 != check2 > 0 ){
//              //we're between these lines!
//              int cornerSplittingIndex = connectTo.corners.get(i);
//              Corner cornerSplitting = masterCs.get(cornerSplittingIndex);
//              cornerSplitting.split(cornerSplittingIndex, thisNew);
//            }
//          } else {
//            //if no swing, we need to know if new line is to the L or R of current line
//            println("this is not the swing you're looking for");
//            float lOrR = det(lineCheck, newLine);
//            Corner thisCorner = GetCorner(connectTo.corners.get(0));
//            int prevCornerID = thisCorner.prev;
//            int nextCornerID = connectTo.corners.get(0);
//            Corner nextCorner = masterCs.get(nextCornerID);
//            Corner prevCorner = masterCs.get(prevCornerID);

//            if( lOrR > 0 ) {
//              //to the right of our line
//              prevCorner.next = masterCs.size();
//              nextCorner.prev =  masterCs.size()+1;
//              thisNew.next = nextCornerID;
//              thisNew.prev = masterCs.size();
//              prevNew.prev = prevCornerID;
//              prevNew.next = masterCs.size()+1;

//            } else {
//              //to the left of our line
//              prevCorner.prev = masterCs.size();
//              nextCorner.next = masterCs.size()+1;
//              thisNew.next = masterCs.size();
//              thisNew.prev = nextCornerID;
//              prevNew.prev = masterCs.size()+1;
//              prevNew.next = prevCornerID;
//            }
//            println("new corner " + masterCs.size() + " between " + thisNew.prev + " and " + thisNew.next);
//          }
         
         
//        }
       
//        prevNew.next = masterCs.size()+1;
      
//        masterCs.add(prevNew);
//        masterCs.add(thisNew);
       
//        prevV.corners.append(masterCs.size()-2); //determine previous vert
//        corners.append(masterCs.size()-1);
//      }
//    }
//    masterVs.add(this);
     
//  }

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
