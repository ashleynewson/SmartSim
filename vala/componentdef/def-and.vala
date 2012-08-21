/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/and.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class AndComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/and.xml";
	
	
	public AndComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			base.from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection[] inputWires = new Connection[componentInst.pinInsts[0].arraySize];
		Connection outputWire = new Connection.fake();
		
		inputWires.resize (componentInst.pinInsts[0].arraySize);
		
		foreach (Connection connection in connections) {
			for (int i = 0; i < componentInst.pinInsts[0].arraySize; i++) {
				WireInst wireInst = componentInst.pinInsts[0].wireInsts[i];
				if (connection.wireInst == wireInst) {
					inputWires[i] = connection;
				}
			}
			if (connection.wireInst == componentInst.pinInsts[1].wireInsts[0]) {
				outputWire = connection;
			}
		}
		
		ComponentState componentState = new AndComponentState (inputWires, outputWire, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}
