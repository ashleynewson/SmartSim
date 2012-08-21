/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/pe-d-flipflop.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class PeDFlipflopComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/pe-d-flipflop.xml";
	
	
	public PeDFlipflopComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			base.from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection dataWire = new Connection.fake();
		Connection clockWire = new Connection.fake();
		Connection outputWire = new Connection.fake();
		Connection outputNotWire = new Connection.fake();
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				dataWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[1].wireInsts[0]) {
				clockWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[2].wireInsts[0]) {
				outputWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[3].wireInsts[0]) {
				outputNotWire = connection;
			}
		}
		
		ComponentState componentState = new PeDFlipflopComponentState (dataWire, clockWire, outputWire, outputNotWire, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}
