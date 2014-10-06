public class VertexHandler {
	private Vertex newVertex;
	private boolean closestToPrevEdge;
	private float distToConnect = 6.0;

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
