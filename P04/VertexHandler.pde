public class VertexHandler {
	private Vertex newVertex;
	private boolean closestToPrevEdge;
	private float distToConnect = 6.0;
	private Vertex connectVertex;

	public void AddVertex(int _x, int _y, int connectIndex) {
		PVector insertionEdge, comparisonEdge;
		newVertex = new Vertex(_x, _y, masterVs.size());
		//println(masterVs.size());

		//check to see if we're connecting two existing vertices
		int idOfExistingConnection = -1;
		for(int i = 0; i < masterVs.size(); i++){
			PVector existingVertPos = new PVector(GetVertexFromID(i).pos.x, GetVertexFromID(i).pos.y);
            PVector tmpNewVert = new PVector(newVertex.pos.x, newVertex.pos.y);
			existingVertPos.sub(tmpNewVert);
			if((abs(existingVertPos.x) < distToConnect) && (abs(existingVertPos.y) < distToConnect)) {
				idOfExistingConnection = i;
				break;
			} 
		}

		if(idOfExistingConnection != -1){
			//connecting two existing verts
			connectVertex = GetVertexFromID(connectIndex);
			ConnectExistingVerts(idOfExistingConnection);
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
				Corner splitCorner = FindEdgesBetween(connectVertex);
				CornerSplit(splitCorner);


			}
		}

		if(idOfExistingConnection == -1) AddToMaster(newVertex);
	}

	private void ConnectExistingVerts(int IDToConnectTo){
		//CONNECTING VERTICES:
		//connectVertex already gloabally created/set
		Vertex farConnection = GetVertexFromID(IDToConnectTo);

		//SPLITTING CORNERS:
		//determine if we need to split corners for both verts
		boolean  connectSplit = false;
		boolean  farSplit = false;
		if(connectVertex.corners.size() > 1) connectSplit = true;
		if(farConnection.corners.size() > 1) farSplit = true;
		//holders for corners we may need
		Corner connectSplitCorner = new Corner();
		Corner farSplitCorner = new Corner();

		if(connectSplit){
			connectSplitCorner = FindEdgesBetween(connectVertex);
			println("split at connection " + connectSplitCorner.id + "for connection");
		}

		if(farSplit){
			farSplitCorner = FindEdgesBetween(farConnection);
			println("split at far corner " + farSplitCorner.id + "for far");
		}

		Corner addedCorner = new Corner(masterCs.size() , connectVertex.id);
		Corner newCorner = new Corner(masterCs.size()+1, farConnection.id);
		//grab existing corners to handle connections from
		Corner originCorner = new Corner();
		Corner farCorner = new Corner();

		if(!connectSplit && !farSplit) {
			originCorner = GetCornerFromID(connectVertex.corners.get(0));
			farCorner = GetCornerFromID(farConnection.corners.get(0));
		} else{
			if(connectSplit) {
				originCorner = connectSplitCorner;
			} else {
				originCorner = GetCornerFromID(connectVertex.corners.get(0));
			}
			if(farSplit) {
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

        AddToMaster(addedCorner);
        AddToMaster(newCorner);

        connectVertex.AddCorner(addedCorner.id);
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

		closestToPrevEdge = (newNewRot - newNextRot) > (2*PI - newNewRot);
		return (newNewRot - newPrevRot > 0) && (newNextRot - newNewRot < 0);
	}

	public int NumCorners(int vertexID) {
		if (vertexID >= 0 && vertexID < masterVs.size()) {
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
