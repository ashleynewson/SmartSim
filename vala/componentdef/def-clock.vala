/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/clock.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ClockComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/clock.xml";
	
	
	public ClockComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			load_from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
		int onFor;
		int offFor;
		
		try {
			onFor = PropertyItemInt.get_data_throw (configurationProperty, "On For");
		} catch {
			onFor = 25;
		}
		queryProperty.add_item (new PropertyItemInt("On For", "Duration which clock is on.", onFor));
		try {
			offFor = PropertyItemInt.get_data_throw (configurationProperty, "Off For");
		} catch {
			offFor = 25;
		}
		queryProperty.add_item (new PropertyItemInt("Off For", "Duration which clock is off.", offFor));
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		int onFor;
		int offFor;
		configurationProperty = new PropertySet (name + " configuration");
		
		onFor = PropertyItemInt.get_data (queryProperty, "On For");
		configurationProperty.add_item (new PropertyItemInt("On For", "", onFor));
		offFor = PropertyItemInt.get_data (queryProperty, "Off For");
		configurationProperty.add_item (new PropertyItemInt("Off For", "", offFor));
	}
	
	public override void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		int onFor = 25;
		int offFor = 25;
		configurationProperty = new PropertySet (name + " configuration");
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "on":
					onFor = int.parse(xmlattr->children->content);
					break;
				case "off":
					offFor = int.parse(xmlattr->children->content);
					break;
			}
		}
		
		configurationProperty.add_item (new PropertyItemInt("On For", "", onFor));
		configurationProperty.add_item (new PropertyItemInt("Off For", "", offFor));
	}
	
	public override void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		int onFor;
		int offFor;
		
		try {
			onFor = PropertyItemInt.get_data_throw (configurationProperty, "On For");
		} catch {
			onFor = 25;
		}
		try {
			offFor = PropertyItemInt.get_data_throw (configurationProperty, "Off For");
		} catch {
			offFor = 25;
		}
//		onFor = PropertyItemInt.get_data (configurationProperty, "On For");
//		offFor = PropertyItemInt.get_data (configurationProperty, "Off For");
		
		xmlWriter.write_attribute ("on", onFor.to_string());
		xmlWriter.write_attribute ("off", offFor.to_string());
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection outputWire = new Connection.fake();
		int onFor;
		int offFor;
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				outputWire = connection;
			}
		}
		
		try {
			onFor = PropertyItemInt.get_data_throw (componentInst.configuration, "On For");
		} catch {
			onFor = 25;
		}
		try {
			offFor = PropertyItemInt.get_data_throw (componentInst.configuration, "Off For");
		} catch {
			offFor = 25;
		}
		
		if (onFor < 1) {
			onFor = 1;
		}
		if (offFor < 1) {
			offFor = 1;
		}
		
		ComponentState componentState = new ClockComponentState (outputWire, onFor, offFor, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
}
