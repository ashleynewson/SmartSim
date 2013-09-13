/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/tristate.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class TristateComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/tristate.xml";
	
	
	public TristateComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			load_from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection inputWire = new Connection.fake();
		Connection controlWire = new Connection.fake();
		Connection outputWire = new Connection.fake();
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				inputWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[1].wireInsts[0]) {
				controlWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[2].wireInsts[0]) {
				outputWire = connection;
			}
		}
		
		ComponentState componentState = new TristateComponentState (inputWire, controlWire, outputWire, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}
