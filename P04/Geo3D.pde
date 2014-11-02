public class Geo3D{
	int planeBelongsTo = 0;
	int outerFace = 1;
	int nextRedraw = -1;
	int swingRedraw = -1;
	int prevRedraw = -1;

	ArrayList<Corner> geoCs = new ArrayList<Corner>();
	ArrayList<Vertex> geoVs = new ArrayList<Vertex>();
	ArrayList<Integer> geoFs = new ArrayList<Integer>();
}