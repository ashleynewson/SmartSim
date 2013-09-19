/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *   
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *   
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *   
 *   Filename: plugincomponents/plugin-def-gpiopin.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public weak PluginComponentManager pluginManager;


public class GpioPinPluginComponentDef : PluginComponentDef {
	private string infoFilename;
	
	
	public GpioPinPluginComponentDef (string infoFilename) throws ComponentDefLoadError.LOAD {
		this.infoFilename = infoFilename;
		
		try {
			load_from_file (infoFilename);
		} catch {
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	~GpioPinPluginComponentDef () {
		pluginManager.print_info ("Unloaded GPIO Pin Component Definition.\n");
	}
	
	public override void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
		PropertyItem gpioNumber = configurationProperty.get_item ("GPIO Pin Number");
		if (gpioNumber != null) {
			queryProperty.add_item (new PropertyItemInt.copy((PropertyItemInt)gpioNumber));
		} else {
			queryProperty.add_item (new PropertyItemInt("GPIO Pin Number", "The pin number in the GPIO system.", 0, 0, int.MAX));
		}
		
		PropertyItem direction = configurationProperty.get_item ("Direction");
		if (direction != null) {
			queryProperty.add_item (new PropertyItemSelection.copy((PropertyItemSelection)direction));
		} else {
			PropertyItemSelection selection = new PropertyItemSelection ("Direction", "Whether the port represents an output or input.");
			selection.add_option ("in", "Input to SmartSim");
			selection.add_option ("low", "Output from SmartSim - Initially Low");
			selection.add_option ("high", "Output from SmartSim - Initially High");
			selection.set_option ("in");
			queryProperty.add_item (selection);
		}
		
		PropertyItem activeState = configurationProperty.get_item ("Active State");
		if (activeState != null) {
			queryProperty.add_item (new PropertyItemSelection.copy((PropertyItemSelection)activeState));
		} else {
			PropertyItemSelection selection = new PropertyItemSelection ("Active State", "Whether a high or low voltage represents 1 (true).");
			selection.add_option ("high", "Active High - High voltage = 1");
			selection.add_option ("low", "Active Low - Low voltage = 1");
			selection.set_option ("high");
			queryProperty.add_item (selection);
		}
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		configurationProperty = new PropertySet (name + " configuration");
		
		configurationProperty.add_item (new PropertyItemInt.copy((PropertyItemInt)queryProperty.get_item("GPIO Pin Number")));
		configurationProperty.add_item (new PropertyItemSelection.copy((PropertyItemSelection)queryProperty.get_item("Direction")));
		configurationProperty.add_item (new PropertyItemSelection.copy((PropertyItemSelection)queryProperty.get_item("Active State")));
	}
	
	public override void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		int gpioNumber = 0;
		string direction = "in";
		string activeState = "high";
		
		configurationProperty = new PropertySet (name + " configuration");
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "number":
					gpioNumber = int.parse(xmlattr->children->content);
					break;
				case "iodirection":
					direction = xmlattr->children->content;
					break;
				case "active":
					activeState = xmlattr->children->content;
					break;
			}
		}
		
		configurationProperty.add_item (new PropertyItemInt("GPIO Pin Number", "The pin number in the GPIO system.", gpioNumber, 0, int.MAX));
		{
			PropertyItemSelection selection = new PropertyItemSelection ("Direction", "Whether the port represents an output or input.");
			selection.add_option ("in", "Input to SmartSim");
			selection.add_option ("low", "Output from SmartSim - Initially Low");
			selection.add_option ("high", "Output from SmartSim - Initially High");
			selection.set_option (direction);
			configurationProperty.add_item (selection);
		}
		{
			PropertyItemSelection selection = new PropertyItemSelection ("Active State", "Whether a high or low voltage represents 1 (true).");
			selection.add_option ("low", "Active High - High voltage = 1");
			selection.add_option ("high", "Active Low - Low voltage = 1");
			selection.set_option (activeState);
			configurationProperty.add_item (selection);
		}
	}
	
	public override void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		int gpioNumber;
		string direction;
		string activeState;
		
		try {
			gpioNumber = PropertyItemInt.get_data_throw (configurationProperty, "GPIO Pin Number");
		} catch {
			gpioNumber = 0;
		}
		try {
			direction = PropertyItemSelection.get_data_throw (configurationProperty, "Direction");
		} catch {
			direction = "in";
		}
		try {
			activeState = PropertyItemSelection.get_data_throw (configurationProperty, "Active State");
		} catch {
			activeState = "high";
		}
		
		xmlWriter.write_attribute ("number", gpioNumber.to_string());
		xmlWriter.write_attribute ("iodirection", direction);
		xmlWriter.write_attribute ("active", activeState);
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection accessWire = new Connection.fake ();
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				accessWire = connection;
			}
		}
		
		/* "in", "high", "low" [, "out"] */
		int gpioNumber;
		string direction;
		bool activeLow;
		
		try {
			gpioNumber = PropertyItemInt.get_data_throw (componentInst.configuration, "GPIO Pin Number");
		} catch {
			gpioNumber = 0;
		}
		try {
			direction = PropertyItemSelection.get_data_throw (componentInst.configuration, "Direction");
		} catch {
			direction = "in";
		}
		try {
			activeLow = (PropertyItemSelection.get_data_throw(componentInst.configuration, "Active State") == "low") ? true : false;
		} catch {
			activeLow = false;
		}
		
		try {
			ComponentState componentState = new GpioPinPluginComponentState (accessWire, gpioNumber, direction, activeLow, ancestry, componentInst);
			compiledCircuit.add_component (componentState);
		} catch (ComponentStateError error) {
			compiledCircuit.appendError (error.message);
			componentInst.errorMark = true;
		}
	}
}


[CCode (cname = "plugin_component_init")]
public bool plugin_component_init (PluginComponentManager manager) {
	pluginManager = manager;
	pluginManager.print_info ("GPIO Pin plugin component initialised.\n");
	GpioPinPluginComponentState.unregister_pins ();
	return true;
}

[CCode (cname = "plugin_component_get_def")]
public PluginComponentDef? plugin_component_get_def (string infoFilename) {
	try {
		PluginComponentDef componentDef = new GpioPinPluginComponentDef (infoFilename);
		return componentDef;
	} catch {
		pluginManager.print_info ("Error during GPIO Pin plugin component def construction!\n");
		return null;
	}
}
