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
 *   Filename: componentdef/def-memory.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class MemoryComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/memory.xml";
	
	
	public MemoryComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			load_from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
		string chipType;
		string readFile;
		string writeFile;
		
		try {
			chipType = PropertyItemSelection.get_data_throw (configurationProperty, "Chip Type");
		} catch {
			chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		}
		PropertyItemSelection chipTypeSelection = new PropertyItemSelection ("Chip Type", "Chip interface options and capabilities");
		chipTypeSelection.add_option ("RAM, Chip Select, Read Enable, Write Enable, Write Clock");
		chipTypeSelection.add_option ("ROM, Chip Select");
		chipTypeSelection.set_option (chipType);
		queryProperty.add_item (chipTypeSelection);
		
		try {
			readFile = PropertyItemFile.get_filename_throw (configurationProperty, "Read File");
		} catch {
			readFile = "";
		}
		queryProperty.add_item (new PropertyItemFile("Read File", "Optional file to load initial memory from.", readFile));
		try {
			writeFile = PropertyItemFile.get_filename_throw (configurationProperty, "Write File");
		} catch {
			writeFile = "";
		}
		queryProperty.add_item (new PropertyItemFile("Write File", "Optional file to save memory to.", writeFile));
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		string chipType;
		string readFile;
		string writeFile;
		
		configurationProperty = new PropertySet (name + " configuration");
		
		try {
			chipType = PropertyItemSelection.get_data_throw (queryProperty, "Chip Type");
		} catch {
			chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		}
		
		configurationProperty = new PropertySet (name + " configuration");
		
		PropertyItemSelection selection = new PropertyItemSelection ("Chip Type", "");
		selection.add_option ("RAM, Chip Select, Read Enable, Write Enable, Write Clock");
		selection.add_option ("ROM, Chip Select");
		selection.set_option (chipType);
		configurationProperty.add_item (selection);
		readFile = PropertyItemFile.get_filename (queryProperty, "Read File");
		configurationProperty.add_item (new PropertyItemFile("Read File", "", readFile));
		writeFile = PropertyItemFile.get_filename (queryProperty, "Write File");
		configurationProperty.add_item (new PropertyItemFile("Write File", "", writeFile));
	}
	
	public override void configure_inst (ComponentInst componentInst, bool firstLoad = false) {
		string chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		
		try {
			chipType = PropertyItemSelection.get_data_throw (componentInst.configuration, "Chip Type");
		} catch {
			chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		}
		
		int addressBound = (int)componentInst.pinInsts[0].pinDef.minSpace * (1 + componentInst.pinInsts[0].arraySize) / 2;
		int dataBound = (int)componentInst.pinInsts[1].pinDef.minSpace * (1 + componentInst.pinInsts[1].arraySize) / 2;
		int newBound = (addressBound > dataBound) ? addressBound : dataBound;
		
		switch (chipType) {
			case "RAM, Chip Select, Read Enable, Write Enable, Write Clock":
				componentInst.pinInsts[3].show = true;
				componentInst.pinInsts[4].show = true;
				componentInst.pinInsts[5].show = true;
				break;
			case "ROM, Chip Select":
				componentInst.pinInsts[3].show = false;
				componentInst.pinInsts[4].show = false;
				componentInst.pinInsts[5].show = false;
				componentInst.pinInsts[3].disconnect (componentInst);
				componentInst.pinInsts[4].disconnect (componentInst);
				componentInst.pinInsts[5].disconnect (componentInst);
				break;
		}
		
		if (componentInst.downBound != newBound && !firstLoad) {
			componentInst.detatch_all ();
		}
		
		componentInst.downBound = newBound;
		componentInst.upBound = -newBound;
		componentInst.pinInsts[2].y[0] = -newBound;
		componentInst.pinInsts[2].update_position ();
		componentInst.pinInsts[3].y[0] = newBound;
		componentInst.pinInsts[3].update_position ();
		componentInst.pinInsts[4].y[0] = newBound;
		componentInst.pinInsts[4].update_position ();
		componentInst.pinInsts[5].y[0] = newBound;
		componentInst.pinInsts[5].update_position ();
	}
	
	public override void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		string chipTypeAttr = "";
		string readFile = "";
		string writeFile = "";
		configurationProperty = new PropertySet (name + " configuration");
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "type":
					chipTypeAttr = xmlattr->children->content;
					break;
				case "read":
					readFile = xmlattr->children->content;
					break;
				case "write":
					writeFile = xmlattr->children->content;
					break;
			}
		}
		
		PropertyItemSelection selection = new PropertyItemSelection ("Chip Type", "");
		selection.add_option ("RAM, Chip Select, Read Enable, Write Enable, Write Clock");
		selection.add_option ("ROM, Chip Select");
		switch (chipTypeAttr) {
			case "RAM-CS-RE-WE-CLK":
				selection.set_option ("RAM, Chip Select, Read Enable, Write Enable, Write Clock");
				break;
			case "ROM-CS":
				selection.set_option ("ROM, Chip Select");
				break;
		}
		configurationProperty.add_item (selection);
		configurationProperty.add_item (new PropertyItemFile("Read File", "", readFile));
		configurationProperty.add_item (new PropertyItemFile("Write File", "", writeFile));
	}
	
	public override void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		string chipType;
		string chipTypeAttr;
		string readFile;
		string writeFile;
		
		try {
			chipType = PropertyItemSelection.get_data_throw (configurationProperty, "Chip Type");
		} catch {
			chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		}
		
		switch (chipType) {
			default:
			case "RAM, Chip Select, Read Enable, Write Enable, Write Clock":
				chipTypeAttr = "RAM-CS-RE-WE-CLK";
				break;
			case "ROM, Chip Select":
				chipTypeAttr = "ROM-CS";
				break;
		}
		
		xmlWriter.write_attribute ("type", chipTypeAttr);
		readFile = PropertyItemFile.get_filename (configurationProperty, "Read File");
		writeFile = PropertyItemFile.get_filename (configurationProperty, "Write File");
		
		if (readFile != "") {
			xmlWriter.write_attribute ("read", readFile);
		}
		if (writeFile != "") {
			xmlWriter.write_attribute ("write", writeFile);
		}
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		Connection[] addressWires = new Connection[componentInst.pinInsts[0].arraySize];
		Connection[] dataWires = new Connection[componentInst.pinInsts[1].arraySize];
		Connection selectWire = new Connection.fake();
		Connection readEnableWire = new Connection.fake();
		Connection writeEnableWire = new Connection.fake();
		Connection clockWire = new Connection.fake();
		string chipType;
		string readFile;
		string writeFile;
		bool readWrite;
		
		foreach (Connection connection in connections) {
			for (int i = 0; i < componentInst.pinInsts[0].arraySize; i++) {
				WireInst wireInst = componentInst.pinInsts[0].wireInsts[i];
				if (connection.wireInst == wireInst) {
					addressWires[i] = connection;
				}
			}
			for (int i = 0; i < componentInst.pinInsts[1].arraySize; i++) {
				WireInst wireInst = componentInst.pinInsts[1].wireInsts[i];
				if (connection.wireInst == wireInst) {
					dataWires[i] = connection;
				}
			}
			if (connection.wireInst == componentInst.pinInsts[2].wireInsts[0]) {
				selectWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[3].wireInsts[0]) {
				readEnableWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[4].wireInsts[0]) {
				writeEnableWire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[5].wireInsts[0]) {
				clockWire = connection;
			}
		}
		
		try {
			chipType = PropertyItemSelection.get_data_throw (componentInst.configuration, "Chip Type");
		} catch {
			chipType = "RAM, Chip Select, Read Enable, Write Enable, Write Clock";
		}
		try {
			readFile = PropertyItemFile.get_filename_throw (componentInst.configuration, "Read File");
		} catch {
			readFile = "";
		}
		try {
			writeFile = PropertyItemFile.get_filename_throw (componentInst.configuration, "Write File");
		} catch {
			writeFile = "";
		}
		
		switch (chipType) {
			default:
			case "RAM, Chip Select, Read Enable, Write Enable, Write Clock":
				readWrite = true;
				break;
			case "ROM, Chip Select":
				readWrite = false;
				break;
		}
		
		ComponentState componentState = null;
		try {
			componentState = new MemoryComponentState (addressWires, dataWires, selectWire, readEnableWire, writeEnableWire, clockWire, readWrite, readFile, writeFile, ancestry, componentInst);
			compiledCircuit.add_component (componentState);
		} catch (ComponentStateError error) {
			compiledCircuit.appendError (error.message);
			componentInst.errorMark = true;
		}
	}
}
