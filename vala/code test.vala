public class SomeObject {
	public string name;
	
	public SomeObject (string name) {
		this.name = name;
	}
}

static int main (string[] args) {
	SomeObject[] someObjects = {};
	SomeObject[] permanentObjects = {};
		
	for (int i = 0; i < 32; i++) {
		someObjects += new SomeObject ( (i + 1000).to_string() );
	}
	
	permanentObjects += someObjects[2];
	permanentObjects += someObjects[3];
	permanentObjects += someObjects[5];
	permanentObjects += someObjects[7];
	permanentObjects += someObjects[11];
	permanentObjects += someObjects[13];
	permanentObjects += someObjects[17];
	permanentObjects += someObjects[19];
	permanentObjects += someObjects[23];
	permanentObjects += someObjects[29];
	permanentObjects += someObjects[31];
	
	UpdateQueue<SomeObject> updateQueue = new UpdateQueue<SomeObject> (someObjects, permanentObjects);
	
	updateQueue.swap (0);
	
	updateQueue.add_element (2);
	updateQueue.add_element (1);
	updateQueue.add_element (0);
	updateQueue.add_element (0);
	updateQueue.add_element (6);
	
	updateQueue.swap (1);
	
	SomeObject someObject;
	someObject = updateQueue.get_next_element();
	while (someObject != null) {
		stdout.printf ("Element name: %s\n", someObject.name);
		someObject = updateQueue.get_next_element();
	}
	
	updateQueue.add_element (3);
	updateQueue.add_element (5);
	
	updateQueue.swap (2);
	
	someObject = updateQueue.get_next_element();
	while (someObject != null) {
		stdout.printf ("Element name: %s\n", someObject.name);
		someObject = updateQueue.get_next_element();
	}
	
	updateQueue.add_element (9);
	updateQueue.add_element (8);
	updateQueue.add_element (7);
	updateQueue.add_element (6);
	updateQueue.add_element (5);
	
	updateQueue.swap (3);
	
	someObject = updateQueue.get_next_element();
	while (someObject != null) {
		stdout.printf ("Element name: %s\n", someObject.name);
		someObject = updateQueue.get_next_element();
	}
	
	return 0;
}
