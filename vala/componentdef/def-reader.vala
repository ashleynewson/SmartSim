/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/reader.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ReaderComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/reader.xml";
	
	
	public ReaderComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			base.from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection inputWire = new Connection.fake();
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				inputWire = connection;
			}
		}
		
		ComponentState componentState = new ReaderComponentState (inputWire, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}
