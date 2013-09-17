/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Example - Public Domain
 *   
 *   Filename: plugincomponents/plugin-def-altand.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public weak PluginComponentManager pluginManager;


public class AndPluginComponentDef : PluginComponentDef {
	private string infoFilename;
	
	
	public AndPluginComponentDef (string infoFilename) throws ComponentDefLoadError.LOAD {
		this.infoFilename = infoFilename;
		
		try {
			load_from_file (infoFilename);
		} catch {
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	~AndPluginComponentDef () {
		pluginManager.print_info ("Unloaded And Plugin.\n");
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
		
		ComponentState componentState = new AndPluginComponentState (inputWires, outputWire, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}


[CCode (cname = "plugin_component_init")]
public bool plugin_component_init (PluginComponentManager manager) {
	pluginManager = manager;
	pluginManager.print_info ("And Plugin Component Init Complete!\n");
	return true;
}

[CCode (cname = "plugin_component_get_def")]
public PluginComponentDef? plugin_component_get_def (string infoFilename) {
	try {
		PluginComponentDef componentDef = new AndPluginComponentDef (infoFilename);
		return componentDef;
	} catch {
		pluginManager.print_info ("Error during plugin component def construction (altand).\n");
		return null;
	}
}
