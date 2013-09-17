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
 *   Filename: componentdef/def-basic-ss-display.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class BasicSsDisplayComponentDef : ComponentDef {
	private const string infoFilename = Config.resourcesDir + "components/info/basic-ss-display.xml";
	
	
	public BasicSsDisplayComponentDef () throws ComponentDefLoadError.LOAD {
		try {
			load_from_file (infoFilename);
		} catch {
			stdout.printf ("Failed to load built in component \"%s\"\n", infoFilename);
			throw new ComponentDefLoadError.LOAD ("Failed to load \"" + infoFilename + "\"\n");
		}
	}
	
	public override void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
		string typeString;
		
		try {
			typeString = PropertyItemSelection.get_data_throw (configurationProperty, "Type");
		} catch {
			typeString = "Hexadecimal";
		}
		
		PropertyItemSelection selection = new PropertyItemSelection ("Type", "The type of seven segment display.");
		selection.add_option ("Hexadecimal");
		selection.add_option ("Hexadecimal with point");
		selection.set_option (typeString);
		queryProperty.add_item (selection);
	}
	
	public override void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		string typeString;
		
		try {
			typeString = PropertyItemSelection.get_data_throw (queryProperty, "Type");
		} catch {
			typeString = "Hexadecimal";
		}
		
		configurationProperty = new PropertySet (name + " configuration");
		
		PropertyItemSelection selection = new PropertyItemSelection ("Type", "");
		selection.add_option ("Hexadecimal");
		selection.add_option ("Hexadecimal with point");
		selection.set_option (typeString);
		configurationProperty.add_item (selection);
	}
	
	public override void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		string typeString = "Hexadecimal";
		
		configurationProperty = new PropertySet (name + " configuration");
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "type":
					typeString = xmlattr->children->content;
					break;
			}
		}
		
		PropertyItemSelection selection = new PropertyItemSelection ("Type", "");
		selection.add_option ("Hexadecimal");
		selection.add_option ("Hexadecimal with point");
		selection.set_option (typeString);
		configurationProperty.add_item (selection);
	}
	
	public override void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		string typeString;
		
		try {
			typeString = PropertyItemSelection.get_data_throw (configurationProperty, "Type");
		} catch {
			typeString = "Hexadecimal";
		}
		
		xmlWriter.write_attribute ("type", typeString);
	}
	
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		string typeString = "Hexadecimal";
		bool displayPoint = false;
		Connection input1Wire = new Connection.fake();
		Connection input2Wire = new Connection.fake();
		Connection input4Wire = new Connection.fake();
		Connection input8Wire = new Connection.fake();
		Connection inputPWire = new Connection.fake();
		
		foreach (Connection connection in connections) {
			if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
				input1Wire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[1].wireInsts[0]) {
				input2Wire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[2].wireInsts[0]) {
				input4Wire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[3].wireInsts[0]) {
				input8Wire = connection;
			}
			if (connection.wireInst == componentInst.pinInsts[4].wireInsts[0]) {
				inputPWire = connection;
			}
		}
		
		try {
			typeString = PropertyItemSelection.get_data_throw (componentInst.configuration, "Type");
		} catch {
			typeString = "Hexadecimal";
		}
		
		switch (typeString) {
			case "Hexadecimal":
				displayPoint = false;
				break;
			case "Hexadecimal with point":
				displayPoint = true;
				break;
		}
		
		ComponentState componentState = new BasicSsDisplayComponentState (input1Wire, input2Wire, input4Wire, input8Wire, inputPWire, displayPoint, ancestry, componentInst);
		
		compiledCircuit.add_component (componentState);
	}
	
	public override void configure_inst (ComponentInst componentInst, bool firstLoad = false) {
		string typeString = "Hexadecimal";
		
		try {
			typeString = PropertyItemSelection.get_data_throw (componentInst.configuration, "Type");
		} catch {
			typeString = "Hexadecimal";
		}
		
		switch (typeString) {
			case "Hexadecimal":
				componentInst.rightBound = 20;
				componentInst.pinInsts[4].show = false;
				componentInst.pinInsts[4].disconnect (componentInst);
				break;
			case "Hexadecimal with point":
				componentInst.rightBound = 30;
				componentInst.pinInsts[4].show = true;
				break;
		}
	}
	
	public override void extra_render (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
		Cairo.Matrix oldmatrix;
		
		context.get_matrix (out oldmatrix);
		
		double oldLineWidth = context.get_line_width ();
		
		double angle;
		
		switch (componentInst.direction) {
			case Direction.DOWN:
				angle = Math.PI * 0.5;
				break;
			case Direction.UP:
				angle = Math.PI * 1.5;
				break;
			default:
				angle = 0;
				break;
		}
		context.rotate (angle);
		
//		context.set_line_width (2);
//		context.set_source_rgb (0.0, 0.0, 0.0);
		
//		context.rectangle (componentInst.leftBound, componentInst.upBound, componentInst.rightBound - componentInst.leftBound, componentInst.downBound - componentInst.upBound);
//		context.stroke ();
		
		context.set_line_width (5);
		
		context.set_source_rgb (0.8, 0.8, 0.8);
		
		
		context.move_to (-12, -30);
		context.line_to ( 12, -30);
		context.stroke ();
		
		context.move_to ( 15, -27);
		context.line_to ( 15,  -3);
		context.stroke ();
		
		context.move_to ( 15,   3);
		context.line_to ( 15,  27);
		context.stroke ();
		
		context.move_to ( 12,  30);
		context.line_to (-12,  30);
		context.stroke ();
		
		context.move_to (-15,  27);
		context.line_to (-15,   3);
		context.stroke ();
		
		context.move_to (-15,  -3);
		context.line_to (-15, -27);
		context.stroke ();
		
		context.move_to ( 12,   0);
		context.line_to (-12,   0);
		context.stroke ();
		
		if (componentInst.pinInsts[4].show) {
			Cairo.LineCap oldLineCap = context.get_line_cap ();
			context.set_line_cap (Cairo.LineCap.ROUND);
			context.set_line_width (8);
			context.move_to (22.5, 27.5);
			context.line_to (22.5, 27.5);
			context.stroke ();
			context.set_line_cap (oldLineCap);
		}
		
		context.set_line_width (oldLineWidth);
		
		context.set_matrix (oldmatrix);
	}
}
