public class VertexHandler {
	private Vertex newVertex;
	private boolean closestToPrevEdge;
	private float distToConnect = 6.0;
	private Vertex connectVertex;
	private boolean successfulCreation = true;
	private boolean inserting = false;
	private int insertionFarVert;

	public boolean AddVertex(int _x, int _y, int connectIndex) {
		PVector insertionEdge, comparisonEdge;
		newVertex = new Vertex(_x, _y, masterVs.size());
		//println(masterVs.size());

		//check to see if we're connecting two existing vertices
		int idOfExistingConnection = -1;
		if(!editing) {
			for(int i = 0; i < masterVs.size(); i++){
				PVector existingVertPos = new PVector(GetVertexFromID(i).pos.x, GetVertexFromID(i).pos.y);
	            PVector tmpNewVert = new PVector(newVertex.pos.x, newVertex.pos.y);
				existingVertPos.sub(tmpNewVert);
				if((abs(existingVertPos.x) < distToConnect) && (abs(existingVertPos.y) < distToConnect)) {
					idOfExistingConnection = i;
					println("vert is on top of another");
					break;
				} 
			}
		}

		if((idOfExistingConnection == connectIndex) && masterVs.size() > 0) return false;

		if(inserting) {
			println("start v: " + connectIndex);
			connectVertex = GetVertexFromID(connectIndex);
			//Corner splitCorner = FindEdgesBetween(connectVertex, newVertex);
			//ConnectExistingVerts(connectVertex, newVertex.id);
			//ConnectExistingVerts(newVertex, idOfExistingConnection);
			InsertVertOnEdge(connectVertex, insertionFarVert);
		}

		if(idOfExistingConnection != -1){
			//connecting two existing verts
			connectVertex = GetVertexFromID(connectIndex);
			println("connecting two existing");
			ConnectExistingVerts(connectVertex, idOfExistingConnection);
		} else {
			if (masterVs.size() == 0) {
				
			} else if (NumCorners(connectIndex) < 1) {
				//println("insert second vert");
				InsertSecondVertex(_x, _y);
			} else if (NumCorners(connectIndex) == 1) {
				//println("adding to end of vert");
				connectVertex = GetVertexFromID(connectIndex);
				AppendToEndOfVertex(connectVertex);

			} else {
				//adding edge between two existing edges
				//println("squeezing between verts");
				connectVertex = GetVertexFromID(connectIndex);
				Corner splitCorner = FindEdgesBetween(connectVertex, newVertex);
				CornerSplit(splitCorner);
			}
		}

		if(idOfExistingConnection == -1 && successfulCreation) {
			//newVertex.startingCorner = masterCs.size()-2;
			//println("(newVertex.startingCorner): "+(newVertex.startingCorner));
			AddToMaster(newVertex);
		}
		if (successfulCreation)
			CheckForFaces();
		return successfulCreation;
	}

	public void InsertVerteXInEdge(int _x, int _y, int _startV, int _endV) {
		inserting = true;
		println("inserting");
		insertionFarVert = _endV;
		AddVertex(_x, _y, _startV);
	}

	private void ConnectExistingVerts(Vertex IDToConnectFrom, int IDToConnectTo){
		//CONNECTING VERTICES:
		//connectVertex already gloabally created/set
		Vertex farConnection = GetVertexFromID(IDToConnectTo);

		//SPLITTING CORNERS:
		//determine if we need to split corners for both verts
		boolean  connectSplit = false;
		boolean  farSplit = false;
		if(IDToConnectFrom.corners.size() > 1) connectSplit = true;
		if(farConnection.corners.size() > 1) farSplit = true;
		//holders for corners we may need
		Corner connectSplitCorner = new Corner();
		Corner farSplitCorner = new Corner();

		if(connectSplit){
			connectSplitCorner = FindEdgesBetween(IDToConnectFrom, newVertex);
			if(connectSplitCorner.id == -1) {
				successfulCreation = false;
				return;
			}
			println("split at connection " + connectSplitCorner.id + "for connection");
		}

		if(farSplit){
			farSplitCorner = FindEdgesBetween(farConnection, IDToConnectFrom);
			if(farSplitCorner.id == -1) {
				successfulCreation = false;
				return;
			}
			println("split at far corner " + farSplitCorner.id + "for far");
		}

		Corner addedCorner = new Corner(masterCs.size() , IDToConnectFrom.id);
		Corner newCorner = new Corner(masterCs.size()+1, farConnection.id);
		//grab existing corners to handle connections from
		Corner originCorner = new Corner();
		Corner farCorner = new Corner();

		if(!connectSplit && !farSplit) {
			println("straight forward split: ");
			originCorner = GetCornerFromID(IDToConnectFrom.corners.get(0));
			farCorner = GetCornerFromID(farConnection.corners.get(0));
		} else{
			if(connectSplit) {
				println("splits at origin");
				originCorner = connectSplitCorner;
			} else {
				originCorner = GetCornerFromID(IDToConnectFrom.corners.get(0));
			}
			if(farSplit) {
				println("splits at far corner");
				farCorner = farSplitCorner;
			} else{
				farCorner = GetCornerFromID(farConnection.corners.get(0));
			}
		}
		
		Corner originsNextC = GetCornerFromID(originCorner.next);
		Corner farsPrevC = GetCornerFromID(farCorner.prev);

		originCorner.next = farCorner.id;
		farCorner.prev = originCorner.id;
		addedCorner.next = originsNextC.id;
		addedCorner.prev = newCorner.id;
		newCorner.next = addedCorner.id;
		newCorner.prev = farsPrevC.id;
		originsNextC.prev = addedCorner.id;
		farsPrevC.next = newCorner.id;

		if(originCorner.swing == -1) {
			addedCorner.swing = originCorner.id;
		} else {
			addedCorner.swing = originCorner.swing;
		}
		originCorner.swing = addedCorner.id;

		if(farCorner.swing == -1) {
			farCorner.swing = newCorner.id;
		} else {
			Corner farUnSwing = farCorner.FindUnswing();
			farUnSwing.swing = newCorner.id;
		}
		newCorner.swing = farCorner.id;
		println("finished splitting corner");

        AddToMaster(addedCorner);
        AddToMaster(newCorner);

        IDToConnectFrom.AddCorner(addedCorner.id);
        farConnection.AddCorner(newCorner.id);
	}

	private void AppendToEndOfVertex(Vertex connectVertex){

		Corner newCorner = new Corner(masterCs.size()+1, newVertex.id);
		Corner addedCorner = new Corner(masterCs.size(), connectVertex.id);
		Corner connectCorner = GetCornerFromID(connectVertex.corners.get(0));
		Corner connectPrevCorner =  GetCornerFromID(connectCorner.prev);
		Corner connectNextCorner = GetCornerFromID(connectCorner.next);

		connectCorner.next = newCorner.id;
		newCorner.prev = connectCorner.id;
		newCorner.next = addedCorner.id;
		addedCorner.prev = newCorner.id;
		addedCorner.next = connectNextCorner.id;
		connectNextCorner.prev = addedCorner.id;

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

	private Corner FindEdgesBetween(Vertex _connectVertex, Vertex _newVertex){
		Corner splitCorner = new Corner();
		//float smallestAngle = 2*PI; 
		for(int i = 0; i < _connectVertex.corners.size(); i++){
			Corner c = GetCornerFromID(_connectVertex.corners.get(i));
			//println("c: " + c.id + "c.next" + c.next + "c.prev: " + c.prev);
			Vertex v = GetVertexFromCornerID(c.id); 
			Vertex vNext = GetVertexFromCornerID(c.next);
			Vertex vPrev = GetVertexFromCornerID(c.prev);

			PVector prevEdge = new PVector(vPrev.pos.x - v.pos.x, vPrev.pos.y - v.pos.y);
			PVector nextEdge = new PVector(vNext.pos.x - v.pos.x, vNext.pos.y - v.pos.y);
			PVector newEdge = new PVector(_newVertex.pos.x - v.pos.x, _newVertex.pos.y - v.pos.y);

			println("check if between corner " + c.id);
			if (IsBetween(prevEdge, newEdge, nextEdge)) {
				println("is between yo");
				splitCorner = c;
				break;
			}
        }

        return splitCorner;

	}

	private void InsertVertOnEdge(Vertex prev, int nextId){
		println("inserting with next " + nextId);
		Vertex next = GetVertexFromID(nextId);

		Corner insert1 = new Corner(masterCs.size(), newVertex.id);
		Corner insert2 = new Corner(masterCs.size()+1, newVertex.id);

		Corner prevCorner = FindCornerWhenOnEdge(prev, next);
		Corner nextCorner = GetCornerFromID(prevCorner.next);
		Corner swingCorner = GetCornerFromID(prevCorner.swing);
		Corner swingPrev = GetCornerFromID(swingCorner.prev);

		// println("***********insert on edge values********");
		// println("prevCorner: "+prevCorner.id);
		// println("nextCorner: "+nextCorner.id);
		// println("swingCorner: "+swingCorner.id);
		// println("swingPrev: "+swingPrev.id);
		// println("***********insert on edge values********");

		prevCorner.next = insert1.id;
		nextCorner.prev = insert1.id;
		insert1.prev = prevCorner.id;
		insert1.next = nextCorner.id;
		insert2.prev = swingPrev.id;
		insert2.next = swingCorner.id;
		swingCorner.prev = insert2.id;
		swingPrev.next = insert2.id;

		insert1.swing = insert2.id;
		insert2.swing = insert1.id;

		AddToMaster(insert1);
		AddToMaster(insert2);
		newVertex.AddCorner(insert1.id);
		newVertex.AddCorner(insert2.id);
	}

	private Corner FindCornerWhenOnEdge(Vertex _prev, Vertex _next) {
		//for all the corners on prev, if the next corner is on our next vert, thats it!
		Corner returnCorner = new Corner();

		for(int i = 0; i < _prev.corners.size(); i++){
			Corner tmp = GetCornerFromID(_prev.corners.get(i));
			Corner tmpNext = GetCornerFromID(tmp.next);
			if(tmpNext.vertex == _next.id){
				returnCorner = tmp;
			}
		}

		return returnCorner;
	}

	private void CornerSplit(Corner splitCorner){
		println("insert at " + splitCorner.id);
		if(splitCorner.id == -1) {
			successfulCreation = false;
			return;
		}

		println("at corner " + splitCorner.id + " and still adding new corners");
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

		//if (closestToPrevEdge) {
			println("closest to prev edge");
			splitPrevCorner.next = addedCorner.id;
			addedCorner.prev = splitPrevCorner.prev;
			addedCorner.next = newCorner.id;
			newCorner.prev = addedCorner.id;
			newCorner.next = splitCorner.id;
			splitCorner.prev = newCorner.id;


			addedCorner.swing = splitCorner.id;
			Corner unSwingCorner = splitCorner.FindUnswing();
			unSwingCorner.swing = addedCorner.id;
		/*} else {
			println("closest to next edge");
			splitCorner.next = newCorner.id;
			newCorner.prev = splitCorner.id;
			newCorner.next = addedCorner.id;
			addedCorner.prev = newCorner.id;
			addedCorner.next = splitNextCorner.id;
			splitNextCorner.prev = addedCorner.id;


			addedCorner.swing = splitCorner.swing;
			//Corner unSwingCorner = splitCorner.FindUnswing();
			splitCorner.swing = addedCorner.id;
		}*/

		AddToMaster(addedCorner);
		AddToMaster(newCorner);
		connectVertex.AddCorner(addedCorner.id);
		newVertex.AddCorner(newCorner.id);

		println("done splitting corner");
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
		PVector newE1 = new PVector(newEdge.x, newEdge.y);
		PVector nextE1 = new PVector(nextEdge.x, nextEdge.y);

		float oldPrevRot = GetPosAngle(prevEdge);
		float oldNewRot = GetPosAngle(newEdge);
		float oldNextRot = GetPosAngle(nextEdge);

		// println("oldPrevRot: "+oldPrevRot);
		// println("oldNewRot: " + oldNewRot);
		// println("oldNextRot: "+oldNextRot);

		float rotAmount = 2*PI - oldPrevRot;

		prevE1.rotate(rotAmount);
		newE1.rotate(rotAmount);
		nextE1.rotate(rotAmount);

		float newPrevRot = GetPosAngle(prevE1);
		float newNewRot = GetPosAngle(newE1);
		float newNextRot = GetPosAngle(nextE1);

		newPrevRot = round(newPrevRot, 2);
		newNewRot = round(newNewRot, 2);
		newNextRot = round(newNextRot, 2);

		// println("newPrevRot: "+newPrevRot);
		// println("newNewRot: " + newNewRot);
		// println("newNextRot: "+newNextRot);

		//closestToPrevEdge = (newNewRot - newNextRot) > (2*PI - newNewRot);

		PVector fromPrev = new PVector(-prevEdge.x, -prevEdge.y);
		PVector toNext = new PVector(nextEdge.x, nextEdge.y);

		return (newNextRot  < newNewRot);
	}

	float round(float val, int dp) {
	  return int(val*pow(10,dp))/pow(10,dp);
	} 


	public int NumCorners(int vertexID) {
		if (vertexID >= 0 && vertexID < masterVs.size()) {
			return GetVertexFromID(vertexID).corners.size();
		} else {
			return 0;
		}
	}

	public void RemoveVertex(int vertexID) {
		Vertex theVertex = GetVertexFromID(vertexID);
		Corner theCorner = GetCornerFromID(vertexID);
		if(theVertex.corners.size() == 1){
			//there's one corner(we're an edge off something)
			Corner nextCorner = GetCornerFromID(theCorner.next);
			if(masterVs.size() == 2) {

			} else {
				Corner prevCorner = GetCornerFromID(theCorner.prev);
				Corner nextNextCorner = GetCornerFromID(GetCornerFromID(theCorner.next).next);
				prevCorner.next = nextNextCorner.id;
				nextNextCorner.prev = prevCorner.id;
				//remove the corners
				CleanCornerReferencesAt(theCorner.id);
				masterCs.remove(theCorner);
				CleanCornerReferencesAt(nextCorner.id);
				masterCs.remove(nextCorner);
				//theCorner.id = -1;
				//nextCorner.id = -1;
			}
		} else if(theVertex.corners.size() >= 2) {

		}
		//else first vertex, just need to kill it
		CleanVertReferencesAt(theVertex.id);
		masterVs.remove(theVertex);

		println("removed vert before exception");
		//theVertex.id = -1;
	}


	public void CleanCornerReferencesAt(int index) {
		for(int i = 0; i < masterCs.size(); i++) {
			Corner currCorner = GetCornerFromID(i);
			if(currCorner.next > index) currCorner.next = currCorner.next - 1;
			if(currCorner.prev > index) currCorner.prev = currCorner.prev - 1;
			if(currCorner.swing > index) currCorner.swing = currCorner.swing -1;
		}
	}

	public void CleanVertReferencesAt(int index) {
		for(int i = 0; i < masterCs.size(); i++) {
			Corner currCorner = GetCornerFromID(i);
			if(currCorner.vertex > index) currCorner.vertex = currCorner.vertex - 1;
		}
	}

	public boolean CheckIfRemovable(Vertex _toRemove){
		if(_toRemove.corners.size() <= 2) return true;

		return false;
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
