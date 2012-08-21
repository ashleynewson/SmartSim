/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/constant.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ConstantComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/constant.xml";
	
	
	public ConstantComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			base.from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
		string constantString;
		
		try {
			constantString = PropertyItemSelection.get_data_throw (configurationProperty, "Value");
		} catch {
			constantString = "0 (False)";
		}
		
		PropertyItemSelection selection = new PropertyItemSelection ("Value", "The constant value to output");
		selection.add_option ("0 (False)");
		selection.add_option ("1 (True)");
		selection.set_option (constantString);
		queryProperty.add_item (selection);
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		string constantString;
		
		try {
			constantString = PropertyItemSelection.get_data_throw (queryProperty, "Value");
		} catch {
			constantString = "0 (False)";
		}
		
		configurationProperty = new PropertySet (name + " configuration");
		
		PropertyItemSelection selection = new PropertyItemSelection ("Value", "");
		selection.add_option ("0 (False)");
		selection.add_option ("1 (True)");
		selection.set_option (constantString);
		configurationProperty.add_item (selection);
	}
	
	public override void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		string constantString = "0 (False)";
		
		configurationProperty = new PropertySet (name + " configuration");
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "value":
					constantString = xmlattr->children->content;
					break;
			}
		}
		
		PropertyItemSelection selection = new PropertyItemSelection ("Value", "");
		selection.add_option ("0 (False)");
		selection.add_option ("1 (True)");
		selection.set_option (constantString);
		configurationProperty.add_item (selection);
	}
	
	public override void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		string constantString;
		
		try {
			constantString = PropertyItemSelection.get_data_throw (configurationProperty, "Value");
		} catch {
			constantString = "0 (False)";
		}
		
		xmlWriter.write_attribute ("value", constantString);
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection outputWire = new Connection.fake();
		
		string constantString;
		bool constantValue = false;
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				outputWire = connection;
			}
		}
		
		try {
			constantString = PropertyItemSelection.get_data_throw (componentInst.configuration, "Value");
		} catch {
			constantString = "0 (False)";
		}
		
		if (constantString == "1 (True)") {
			constantValue = true;
		}
		
		ComponentState componentState = new ConstantComponentState (outputWire, constantValue, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
	
	public override void extra_render (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
		string constantString;
		string text;
		
		if (componentInst == null) {
			return;
		}
		
		context.set_source_rgb (0, 0, 0);
		
		try {
			constantString = PropertyItemSelection.get_data_throw (componentInst.configuration, "Value");
		} catch {
			constantString = "0 (False)";
		}
		
		if (constantString == "1 (True)") {
			text = "1";
		} else {
			text = "0";
		}
		
		Cairo.TextExtents textExtents;
		
		context.set_font_size (16);
		context.text_extents (text, out textExtents);
		context.move_to (-textExtents.width/2, +textExtents.height/2);
		context.show_text (text);
	}
}
