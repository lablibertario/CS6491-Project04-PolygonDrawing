import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class P04 extends PApplet {

/**************************** HEADER ****************************
 LecturesInGraphics: Template for Processing sketches in 2D
 Template author: Jarek ROSSIGNAC
 Class: CS3451 Fall 2014
 Student: Miranda Bradley and Sebastian Monroy
 Project number: 4
 Project title: Graphs!
 Date of submission: ??
 *****************************************************************/


//**************************** global variables ****************************

//*************** text drawn on the canvas for name, title and help  *******************
String title ="CS3451, Fall 2014, Project 04: Graphs!", name ="Miranda Bradley and Sebastian Monroy", // enter project number and your name
menu="?:(show/hide) help, !:snap picture, ~:(start/stop) recording frames for movie, Q:quit", 
guide="Press&drag mouse to move dot. 'x', 'y' restrict motion"; // help info
// velocityDisplay=Float.toString(velocity)

ArrayList<Corner> masterCs = new ArrayList<Corner>();
ArrayList<Vertex> masterVs = new ArrayList<Vertex>();
IntList masterFs = new IntList();

VertexHandler vertexHandler = new VertexHandler();

//**************************** initialization ****************************
public void setup() {               // executed once at the begining 
  size(600, 600);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/pic.jpg");  // loads image from file pic.jpg in folder data, replace it with a clear pic of your face
  myFace2 = loadImage("data/pic2.jpg");
  power = loadImage("data/power.png"); // loads power image
  
  
  //hard coded points! for testing
  vertexHandler.AddVertex(50, 50, -1);
  vertexHandler.AddVertex(250, 250, 0);
  vertexHandler.AddVertex(300, 400, 1);
  vertexHandler.AddVertex(400, 250, 2);
  vertexHandler.AddVertex(100, 250, 1);
 // vertexHandler.AddVertex(55, 55, 1);

  //PVector temp = new PVector(-1,0);
  //println("/////////" + temp.heading());
}

//**************************** display current frame ****************************
public void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  pen(black, 3); // sets stroke color (to balck) and width (to 3 pixels)

  if (keyPressed) {
    fill(black); 
    text(key, mouseX-2, mouseY);
  } // writes the character of key if still pressed
  if (!mousePressed && !keyPressed) scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed

  displayHeader();
  if (scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if (filming && (animating || change)) saveFrame("FRAMES/"+nf(frameCounter++, 4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
  // make sure that animating is set to true at the beginning of an animation and to false at the end

  displayEdges();
  displayVertices();
  displayCorners();
  
}  // end of draw()


//************************* mouse and key actions ****************************
public void keyPressed() { // executed each time a key is pressed: the "key" variable contains the correspoinding char, 
  if (key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if (key=='!') snapPicture(); // make a picture of the canvas
  if (key=='~') { 
    filming=!filming;
  } // filming on/off capture frames into folder FRAMES
  if (key==' ') {

  } // reset the blue ball at the center of the screen
  if (key=='a') animating=true;  // quit application
  if (key=='Q') exit();  // quit application
  change=true;
}

public void keyReleased() { // executed each time a key is released
  if (key=='b') {

  }
  if (key=='a') animating=false;  // quit application
  change=true;
}

public void mouseDragged() { // executed when mouse is pressed and moved
  change=true;
}

public void mouseMoved() { // when mouse is moved
  change=true;
}

public void mousePressed(MouseEvent e) { // when mouse key is pressed 

}

public void mouseReleased(MouseEvent e) { // when mouse key is released 

}

public Corner GetCornerFromID(int cornerID) {
  return masterCs.get(cornerID);
}
 
public Vertex GetVertexFromCornerID(int cornerID) {
  return masterVs.get(masterCs.get(cornerID).vertex);
}

public Vertex GetVertexFromID(int vertexID) {
  return masterVs.get(vertexID);
}



public class Corner{
  int id;
  int next, prev, swing, vertex;
  boolean visited;

  public Corner(){
    id = -1;
    visited = false;
    swing = -1;
  }

  public Corner(int cornerID) {
    id = cornerID;
    visited = false;
    swing = -1;
  }

  public Corner(int cornerID, int vertexID) {
    id = cornerID;
    visited = false;
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

  public void Draw() {
    fill(red);
    stroke(red);
    Corner tmp = masterCs.get(id);
    // println("corner " + id + " has next: " + tmp.next + " and prev: " + tmp.prev);
  //  println("stored next " + next + "stored prev: " + prev);
    PVector pos = GetDisplayPosition();
    showDisk(pos.x, pos.y, 2); 
  }

  public Corner FindUnswing(){
    Corner currCorner = this;
    while(currCorner.swing != id){
      currCorner = GetCornerFromID(currCorner.swing);
    }

    return currCorner;
  }

}
/* TO DOs for a project
Fill in file header on the main tab (Project??) with your name, project number, title, and date.
Make sure that you replace the data/pic.jpg with a picture of your face. Your .jpg file should have 
roughly same dimensions as mine so the image fits in the corner. 
Your picture should be recent and should clearly show your face.
Edit the title and name at the bottom of this file with the project number, title, and your name.
Write your own code as a procedure in a separate tab. Make sure to put a header in that tab with your name.
Be concise. Write elegant and readable code. Put brief comments as needed.
ALL CODE THAT YOU ADD SHOULD BE WRITTEN ENTIRELY AND ONLY BY YOU! NO COLLABORATION ON THE CODE.
YOU ARE NOT ALLOWED TO COPY CODE FROM ANY OTHER SOURCES UNLESS EXPLICITLY PERMITTED BY THE INSTRUCTOR OR TA.
Sources of inspiration must be clearly indicated as comments in the code and in the report.
These may include discussions with colleagues (give names and be specific as to what waw discussed), 
help from TA (state which part), cite books, papers, websites that were helpful (be specific which part was helpful).
Add commands to draw() and to the various action procedures to call your procedure(s) and support your GUI and animation.
Edit the 'guide' string as desired to explain the GUI of your program.
Capture images of the canvas ('!') showing results of your program and include in the write-up for your submission.
Follow the indication in the 'utilities' tab on how to make a movie showing your sketch in action.
Make sure that your movie is short (~10 secs) and that the resolution is modest, so that the file is small.
Write a short report containing 
 - the title: CS3451-Fall 2013, Project0?, 
 - author: First LASTNAME, clear image of your face.
 - project title, and short description of what was asked,
 - a short explanation of what you did and how 
   (include a code snippet showing the key pieces of what you have programmed), 
 - include images showing that your program works, 
 - explain clearly what functionality you were not able to implement and why,
 - clearly identify EXTRA CREDIT contributions and include explanations and images showing them.
   (only up to 25% of the extra credit points can be earned per project).
   
Include the source code sketch tabs, the data folder, the movie, and a PDF of your report inside the sketch folder.
Make sure that you DELETE the FRAMES folder and the PICTURES folder.
Compress the sketch folder into a .zip file and submit the zipped file on Tsquare before the deadline. (No extensions!)
*/

/**************************** to make a movie **************************
Press '~' to start recording frames
Use the program
Press '~' again to stop recording
You may press '~' again later to append frames and again to stop 
This creates a folder namesd FRAMES (if it did not exist).
If you already had such a folder, you should delete it before running this program.
NOw, go to the top meny of Processing. Select TOOLS and Movie Maker.
Choose the FRAMES folder. Leave the with and height to 600. frames rate to 30, and compression to Animation.
Press Create Movie... and specify the name of the output file (for project xx: Pxx followed by your last name)

************************************************************************/
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

  public void Draw() {
    stroke(black);
    noFill();

    showDisk(pos.x, pos.y, 10);
  }
}
public class VertexHandler {
	private Vertex newVertex;
	private boolean closestToPrevEdge;
	private float distToConnect = 6.0f;

	public void AddVertex(int _x, int _y, int connectIndex) {
		PVector insertionEdge, comparisonEdge;
		newVertex = new Vertex(_x, _y, masterVs.size());
		println(masterVs.size());
		Vertex connectVertex;

		//check to see if we're connecting two existing vertices
		int idOfExistingConnection = -1;
		/*for(int i = 0; i < masterVs.size(); i++){
			PVector existingVertPos = new PVector(GetVertexFromID(i).pos.x, GetVertexFromID(i).pos.y);
                        PVector tmpNewVert = new PVector(newVertex.pos.x, newVertex.pos.y);
			existingVertPos.sub(tmpNewVert);
                        println("x dist: " + existingVertPos.x + "ydist: " + existingVertPos.y);
			if((abs(existingVertPos.x) < distToConnect) && (abs(existingVertPos.y) < distToConnect)) {
				idOfExistingConnection = i;
				break;
			} 
		}*/

		if(idOfExistingConnection != -1){
			println("connecting two existing verts");
			ConnectExistingVerts(idOfExistingConnection);
		} else {
			if (masterVs.size() == 0) {
				
			} else if (NumCorners(connectIndex) < 1) {
				InsertSecondVertex(_x, _y);
			} else if (NumCorners(connectIndex) == 1) {
				connectVertex = GetVertexFromID(connectIndex);
				AppendToEndOfVertex(connectVertex);

			} else {
				//adding edge between two existing edges
				connectVertex = GetVertexFromID(connectIndex);
				Corner splitCorner = FindEdgesBetween(connectVertex);
				CornerSplit(splitCorner);


			}
		}

		AddToMaster(newVertex);
	}

	private void ConnectExistingVerts(int IDToConnectTo){
		
	}

	private void AppendToEndOfVertex(Vertex connectVertex){

		Corner newCorner = new Corner(masterCs.size()+1, newVertex.id);
		Corner addedCorner = new Corner(masterCs.size(), connectVertex.id);
		Corner connectCorner = GetCornerFromID(connectVertex.corners.get(0));
		Corner connectPrevCorner =  GetCornerFromID(connectCorner.prev);

		connectCorner.next = newCorner.id;
		newCorner.prev = connectCorner.id;
		newCorner.next = addedCorner.id;
		addedCorner.prev = newCorner.id;

		if(connectPrevCorner.swing != -1) {
			addedCorner.next = connectPrevCorner.swing;
		} else {
			addedCorner.next = connectPrevCorner.id;
		}

		connectCorner.swing = addedCorner.id;
		addedCorner.swing = connectCorner.id;


		AddToMaster(addedCorner);
		AddToMaster(newCorner);
		connectVertex.AddCorner(addedCorner.id);
		newVertex.AddCorner(newCorner.id);
	}

	private Corner FindEdgesBetween(Vertex _connectVertex){
		Corner splitCorner = new Corner();
		//float smallestAngle = 2*PI; 
		for(int i = 0; i < _connectVertex.corners.size(); i++){
			Corner c = GetCornerFromID(_connectVertex.corners.get(i));
			Vertex v = GetVertexFromCornerID(c.id);
			Vertex vNext = GetVertexFromCornerID(c.next);
			Vertex vPrev = GetVertexFromCornerID(c.prev);

			PVector prevEdge = new PVector(vPrev.pos.x - v.pos.x, vPrev.pos.y - v.pos.y);
			PVector nextEdge = new PVector(vNext.pos.x - v.pos.x, vNext.pos.y - v.pos.y);
			PVector newEdge = new PVector(newVertex.pos.x - v.pos.x, newVertex.pos.y - v.pos.y);
			println("prevEdge: "+prevEdge);
			println("nextEdge: "+nextEdge);
			println("newEdge: "+newEdge);

			//float angleBetween = GetSmallestAngle(prevEdge, newEdge);
			//println("angle: " + angleBetween);
			//if(angleBetween < smallestAngle && !isToRightOf(prevEdge, newEdge)) {
			if (IsBetween(prevEdge, newEdge, nextEdge)) {
				println("is between yo");
				//smallestAngle = angleBetween;
				splitCorner = c;
				break;
			}
			//boolean check1 = isToRightOf(prevEdge, newEdge);
			//boolean check2 = isToRightOf(newEdge, nextEdge);
           // println("check1: "+ check1 + " check2: " + check2);
            //see if our new edge is between these previous two
            // if( check1 == check2 ){
            // 	//we're between the lines!
            // 	println("between the lines!");
            // 	splitCorner = c;
            // 	break;
            // }
        }

        return splitCorner;

	}

	private void CornerSplit(Corner splitCorner){
		println("insert at " + splitCorner.id);

		Vertex connectVertex = GetVertexFromCornerID(splitCorner.id);

		Corner newCorner = new Corner(masterCs.size()+1, newVertex.id);
		Corner addedCorner = new Corner(masterCs.size(), connectVertex.id);

		Corner splitPrevCorner = GetCornerFromID(splitCorner.prev);
		Corner splitNextCorner =  GetCornerFromID(splitCorner.next);

		Vertex prevVertex = GetVertexFromCornerID(splitCorner.prev);
		Vertex nextVertex = GetVertexFromCornerID(splitCorner.next);

		PVector prevEdge = new PVector(prevVertex.pos.x - connectVertex.pos.x, prevVertex.pos.y - connectVertex.pos.y);
		PVector nextEdge = new PVector(nextVertex.pos.x - connectVertex.pos.x, nextVertex.pos.y - connectVertex.pos.y);
		PVector newEdge = new PVector(newVertex.pos.x - connectVertex.pos.x, newVertex.pos.y - connectVertex.pos.y);

		if (closestToPrevEdge) {
			println("closest to prev edge");
			splitPrevCorner.next = addedCorner.id;
			addedCorner.prev = splitPrevCorner.id;
			addedCorner.next = newCorner.id;
			newCorner.prev = addedCorner.id;
			newCorner.next = splitCorner.id;
			splitCorner.prev = newCorner.id;
			addedCorner.swing = splitCorner.id;
			Corner unSwingCorner = splitCorner.FindUnswing();
			unSwingCorner.swing = addedCorner.id;
		} else {
			println("closest to next edge");
			splitCorner.next = newCorner.id;
			newCorner.prev = splitCorner.id;
			newCorner.next = addedCorner.id;
			addedCorner.prev = newCorner.id;
			addedCorner.next = splitNextCorner.id;
			splitNextCorner.prev = addedCorner.id;
			addedCorner.swing = splitCorner.swing;
			splitCorner.swing = addedCorner.id;
		}

		AddToMaster(addedCorner);
		AddToMaster(newCorner);
		connectVertex.AddCorner(addedCorner.id);
		newVertex.AddCorner(newCorner.id);
	}

	private Direction VertexDirection(PVector comparison, PVector insertion) {
		float thing = det(comparison, insertion);
		if (thing > 0) {
			return Direction.RIGHT;
		} else if (thing == 0) {
			return null;
		} else {
			return Direction.LEFT;
		}
	}

	private void InsertSecondVertex(int _x, int _y) {
		Vertex firstVertex = GetVertexFromID(0);
		Corner firstCorner = new Corner(0, firstVertex.id);
		Corner newCorner = new Corner(1, newVertex.id);

		firstCorner.next = newCorner.id;
		firstCorner.prev = newCorner.id;
		newCorner.next = firstCorner.id;
		newCorner.prev = firstCorner.id;
        
        AddToMaster(firstCorner);
        AddToMaster(newCorner);

        firstVertex.AddCorner(firstCorner.id);
        newVertex.AddCorner(newCorner.id);
	}

	private boolean IsBetween(PVector prevEdge, PVector newEdge, PVector nextEdge) {
		PVector prevE1 = new PVector(prevEdge.x, prevEdge.y);
		// PVector prevE2 = new PVector(prevEdge.x, prevEdge.y);
		PVector newE1 = new PVector(newEdge.x, newEdge.y);
		// PVector newE2 = new PVector(newEdge.x, newEdge.y);
		PVector nextE1 = new PVector(nextEdge.x, nextEdge.y);
		// PVector nextE2 = new PVector(nextEdge.x, nextEdge.y);

		float oldPrevRot = GetPosAngle(prevEdge);
		float oldNewRot = GetPosAngle(newEdge);
		float oldNextRot = GetPosAngle(nextEdge);

		float rotAmount = 2*PI - oldPrevRot;

		prevE1.rotate(rotAmount);
		newE1.rotate(rotAmount);
		nextE1.rotate(rotAmount);

		float newPrevRot = GetPosAngle(prevE1);
		float newNewRot = GetPosAngle(newE1);
		float newNextRot = GetPosAngle(nextE1);

		// println("oldPrev " + oldPrevRot + " oldNew " + oldNewRot + " oldNext " + oldNextRot);
		// println("newPrev " + newPrevRot + " newNew " + newNewRot + " newNext " + newNextRot);
		// println("new " + newNewRot);
		// println("new-next " + (newNewRot-newNextRot) + ", 2PI - new " + (2*PI-newNewRot));
		closestToPrevEdge = (newNewRot - newNextRot) > (2*PI - newNewRot);
		return (newNewRot - newPrevRot > 0) && (newNextRot - newNewRot < 0);
	}

	public int NumCorners(int vertexID) {
		if (vertexID > 0 && vertexID < masterVs.size()) {
			return GetVertexFromID(vertexID).corners.size();
		} else {
			return 0;
		}
	}

	public void RemoveVertex(int vertexID) {

	}

	public void AddToMaster(Vertex _newVertex) {
		masterVs.add(_newVertex);
	}

	public void AddToMaster(Corner _newCorner) {
		masterCs.add(_newCorner);
	}

	public float GetSmallestAngle(PVector tempa, PVector tempb) {
		PVector a1 = new PVector(tempa.x, tempa.y);
		PVector b1 = new PVector(tempb.x, tempb.y);
		PVector a2 = new PVector(tempa.x, tempa.y);
		PVector b2 = new PVector(tempb.x, tempb.y);

		return min(GetAngle(a1, b1), GetAngle(b1, a1));
	}

	
}
// LecturesInGraphics: utilities
// Colors, pictures, text formatting
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012

// ************************************************************************ COLORS 
int black=0xff000000, white=0xffFFFFFF, // set more colors using Menu >  Tools > Color Selector
red=0xffFF0000, green=0xff00FF01, blue=0xff0300FF, yellow=0xffFEFF00, cyan=0xff00FDFF, magenta=0xffFF00FB;

// ************************************************************************ GRAPHICS 
public void pen(int c, float w) {
  stroke(c); 
  strokeWeight(w);
}
public void showDisk(float x, float y, float r) {
  ellipse(x, y, r*2, r*2);
}

public float det(PVector a, PVector b) { //may be a terrible terrible thing
  PVector aRot = new PVector(-a.y, a.x);
  return aRot.dot(b);
}

public boolean isToRightOf(PVector a, PVector b){
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
public void snapPicture() {
  saveFrame("PICTURES/P"+nf(pictureCounter++, 3)+".jpg");
}

// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
public void scribe(String S, float x, float y) {
  fill(0); 
  text(S, x, y); 
  noFill();
} // writes on screen at (x,y) with current fill color
public void scribeHeader(String S, int i) {
  fill(0); 
  text(S, 10, 20+i*20); 
  noFill();
} // writes black at line i
public void scribeHeaderRight(String S) {
  fill(0); 
  text(S, width-7.5f*S.length(), 20); 
  noFill();
} // writes black on screen top, right-aligned
public void scribeFooter(String S, int i) {
  fill(0); 
  text(S, 10, height-10-i*20); 
  noFill();
} // writes black on screen at line i from bottom
public void scribeAtMouse(String S) {
  fill(0); 
  text(S, mouseX, mouseY);
  noFill();
} // writes on screen near mouse
public void scribeMouseCoordinates() {
  fill(black); 
  text("("+mouseX+","+mouseY+")", mouseX+7, mouseY+25); 
  noFill();
}
public void displayHeader() { // Displays title and authors face on screen
  scribeHeader(title, 0); 
  scribeHeaderRight(name); 
  image(myFace, width-myFace.width/2, 25, myFace.width/2, myFace.height/2); 
  image(myFace2, (width-myFace.width), 25, myFace.width/2, myFace.height/2);
}
public void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

public void displayVertices() {
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

public void displayCorners() {
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

public void displayEdges() {
  for (int i = 0; i < masterCs.size(); i++) {
    Corner c = masterCs.get(i);
    Vertex startV = GetVertexFromCornerID(c.id);
    Vertex endV = GetVertexFromCornerID(c.next);
    DrawLine(startV.pos, endV.pos, 2, blue);
    DrawSidewalk(GetCornerFromID(c.id), GetCornerFromID(c.next));
  }
}

public void DrawLine(PVector start, PVector end, float thickness, int rgb) {
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

public void DrawSidewalk(Corner startC, Corner endC) {
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

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "P04" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
