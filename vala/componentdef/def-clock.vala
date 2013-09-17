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
 *   Filename: componentdef/def-clock.vala
 *   
 *   Copyright Ashley Newson 2013
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
		queryProperty.add_item (new PropertyItemInt("On For", "Duration which clock is on.", onFor, 1, int.MAX));
		try {
			offFor = PropertyItemInt.get_data_throw (configurationProperty, "Off For");
		} catch {
			offFor = 25;
		}
		queryProperty.add_item (new PropertyItemInt("Off For", "Duration which clock is off.", offFor, 1, int.MAX));
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		int onFor;
		int offFor;
		configurationProperty = new PropertySet (name + " configuration");
		
		onFor = PropertyItemInt.get_data (queryProperty, "On For");
		configurationProperty.add_item (new PropertyItemInt("On For", "", onFor, 1, int.MAX));
		offFor = PropertyItemInt.get_data (queryProperty, "Off For");
		configurationProperty.add_item (new PropertyItemInt("Off For", "", offFor, 1, int.MAX));
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
		
		configurationProperty.add_item (new PropertyItemInt("On For", "", onFor, 1, int.MAX));
		configurationProperty.add_item (new PropertyItemInt("Off For", "", offFor, 1, int.MAX));
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
