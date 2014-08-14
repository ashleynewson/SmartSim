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
 *   Filename: pindef.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * Definition of a pin.
 * 
 * Used to describe how a pin should appear, and properties such as
 * required connections, and arrays.
 */
public class PinDef {
	/**
	 * The x position the pin extends from.
	 */
	public int x;
	/**
	 * The y position the pin extends from.
	 */
	public int y;
	/**
	 * The x position of the pin's box design label.
	 */
	public int xLabel;
	/**
	 * The y position of the pin's box design label.
	 */
	public int yLabel;
	/**
	 * The x position the pin extends to.
	 */
	public int xConnect;
	/**
	 * The y position the pin extends to.
	 */
	public int yConnect;
	/**
	 * The direction in which the pin extends.
	 */
	public Direction direction;
	/**
	 * How far the pin extends.
	 */
	public int length;
	/**
	 * Whether or not the pin is an array of pins.
	 */
	public bool array;
	/**
	 * Whether the pin is an input, output, bidirectional.
	 */
	public Flow flow;
	/**
	 * The default size of a pin array. Set to 1 if not an array.
	 */
	public int defaultArraySize;
	/**
	 * Total array spacing to try and fit to.
	 */
	public int idealSpace;
	/**
	 * The minimum space between pins in an array.
	 */
	public float minSpace;
	/**
	 * Label to use in a box design.
	 */
	public string label;
	/**
	 * Whether or not the pin requires a connection.
	 */
	public bool required;
	public bool userArrayResize;
	public bool showDefault;
	
	/**
	 * Describes the appearance of the label
	 */
	public enum LabelType {
		NONE,
		TEXT,
		TEXTBAR,
		CLOCK
	}
	
	/**
	 * The appearance of the label
	 */
	public LabelType labelType;
	
	/**
	 * Creates a new PinDef which the given properties.
	 */
	public PinDef (int x, int y, Direction direction, Flow flow, int length, bool array, int defaultArraySize = 1, int idealSpace = 0, float minSpace = 0, string label = "", LabelType labelType = LabelType.NONE, bool required = true, bool userArrayResize = true, bool showDefault = true) {
		this.flow = flow;
		this.array = array;
		this.defaultArraySize = defaultArraySize;
		this.idealSpace = idealSpace;
		this.minSpace = minSpace;
		this.label = label;
		this.labelType = labelType;
		this.required = required;
		this.userArrayResize = userArrayResize;
		this.showDefault = showDefault;
		
		set_position (x, y, length, direction);
	}
	
	/**
	 * Loads a PinDef from a file using libxml.
	 */
	public PinDef.load (Xml.Node* xmlnode) {
		this.flow = Flow.NONE;
		this.array = false;
		this.defaultArraySize = 1;
		this.idealSpace = 0;
		this.minSpace = 0;
		this.label = "";
		this.labelType = LabelType.NONE;
		this.required = true;
		this.userArrayResize = true;
		this.showDefault = true;
		
		int x = 0;
		int y = 0;
		Direction direction = Direction.NONE;
		int length = 1;
		
		for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
			switch (xmlattr->name) {
				case "x":
					x = int.parse(xmlattr->children->content);
					break;
				case "y":
					y = int.parse(xmlattr->children->content);
					break;
				case "direction":
					switch (xmlattr->children->content) {
						default:
							direction = Direction.NONE;
							break;
						case "left":
							direction = Direction.LEFT;
							break;
						case "down":
							direction = Direction.DOWN;
							break;
						case "right":
							direction = Direction.RIGHT;
							break;
						case "up":
							direction = Direction.UP;
							break;
					}
					break;
				case "length":
					length = int.parse(xmlattr->children->content);
					break;
				case "flow":
					switch (xmlattr->children->content) {
						default:
							stdout.printf ("Error: Invalid flow\n");
							break;
						case "in":
							flow = Flow.IN;
							break;
						case "out":
							flow = Flow.OUT;
							break;
						case "bi":
							flow = Flow.BIDIRECTIONAL;
							break;
					}
					break;
				case "array":
					array = bool.parse (xmlattr->children->content);
					break;
				case "arraydefault":
					defaultArraySize = int.parse(xmlattr->children->content);
					break;
				case "idealspace":
					idealSpace = int.parse(xmlattr->children->content);
					break;
				case "minspace":
					minSpace = (float)(double.parse(xmlattr->children->content));
					break;
				case "label":
					label = xmlattr->children->content;
					labelType = LabelType.TEXT;
					break;
				case "barlabel":
					label = xmlattr->children->content;
					labelType = LabelType.TEXTBAR;
					break;
				case "symlabel":
					switch (xmlattr->children->content) {
						default:
							labelType = LabelType.NONE;
							break;
						case "clock":
							labelType = LabelType.CLOCK;
							break;
					}
					break;
				case "required":
					required = bool.parse (xmlattr->children->content);
					break;
				case "userresize":
					userArrayResize = bool.parse (xmlattr->children->content);
					break;
				case "show":
					showDefault = bool.parse (xmlattr->children->content);
					break;
			}
		}
		if (flow == Flow.NONE) {
			stdout.printf ("Warning: No flow\n");
		}
		
		set_position (x, y, length, direction);
	}
	
	/**
	 * Changes the position the pin extends from, its length, and
	 * direction, updating necessary values.
	 */
	public void set_position (int x, int y, int length, Direction direction) {
		this.x = x;
		this.y = y;
		this.length = length;
		this.direction = direction;
		
		switch (direction) {
			case Direction.NONE:
				xConnect = x;
				yConnect = y;
				xLabel = x;
				yLabel = y;
				break;
			case Direction.RIGHT:
				xConnect = x + length;
				yConnect = y;
				xLabel = x - 10;
				yLabel = y;
				break;
			case Direction.DOWN:
				xConnect = x;
				yConnect = y + length;
				xLabel = x;
				yLabel = y - 10;
				break;
			case Direction.LEFT:
				xConnect = x - length;
				yConnect = y;
				xLabel = x + 10;
				yLabel = y;
				break;
			case Direction.UP:
				xConnect = x;
				yConnect = y - length;
				xLabel = x;
				yLabel = y + 10;
				break;
		}
	}
	
	/**
	 * Saves the PinDef to a file using libxml.
	 */
	public void save (Xml.TextWriter xmlWriter, int id) {
		xmlWriter.start_element ("pin");
		
		xmlWriter.write_attribute ("x", x.to_string());
		xmlWriter.write_attribute ("y", y.to_string());
		xmlWriter.write_attribute ("length", length.to_string());
		string tmpString;
		switch (direction) {
			case Direction.RIGHT:
				tmpString = "right";
				break;
			case Direction.DOWN:
				tmpString = "down";
				break;
			case Direction.LEFT:
				tmpString = "left";
				break;
			case Direction.UP:
				tmpString = "up";
				break;
			default:
				tmpString = "none";
				break;
		}
		xmlWriter.write_attribute ("direction", tmpString);
		xmlWriter.write_attribute ("id", id.to_string());
		switch (flow) {
			case Flow.IN:
				xmlWriter.write_attribute ("flow", "in");
				break;
			case Flow.OUT:
				xmlWriter.write_attribute ("flow", "out");
				break;
			case Flow.BIDIRECTIONAL:
				xmlWriter.write_attribute ("flow", "bi");
				break;
		}
		
		switch (labelType) {
			case LabelType.TEXT:
				xmlWriter.write_attribute ("label", label);
				break;
			case LabelType.TEXTBAR:
				xmlWriter.write_attribute ("barlabel", label);
				break;
			case LabelType.CLOCK:
				xmlWriter.write_attribute ("symlabel", "clock");
				break;
		}
		
		xmlWriter.write_attribute ("required", required ? "true" : "false");
//		Uncomment if needed:
	//	xmlWriter.write_attribute ("userresize", userArrayResize ? "true" : "false");
	//	xmlWriter.write_attribute ("show", showDefault ? "true" : "false");
		
		xmlWriter.end_element ();
	}
	
	/**
	 * Renders the pin (without label). If //invert// is true, a small
	 * circle is displayed on the start of the pin.
	 */
	public void render (Cairo.Context context, bool invert) {
		Cairo.Matrix oldMatrix;
		
		oldMatrix = context.get_matrix ();
		context.translate (x, y);
		
		if (direction != Direction.NONE) {
			double angle = 0;
			
			switch (direction) {
				case Direction.RIGHT:
					angle = 0;
					break;
				case Direction.DOWN:
					angle = Math.PI * 0.5;
					break;
				case Direction.LEFT:
					angle = Math.PI;
					break;
				case Direction.UP:
					angle = Math.PI * 1.5;
					break;
			}
			context.rotate (angle);
			if (invert) {
				context.move_to (10, 0);
				context.line_to (length, 0);
				context.arc (5, 0, 5, 0, Math.PI * 2);
				context.stroke ();
			} else {
				context.move_to (0, 0);
				context.line_to (length, 0);
				context.stroke ();
			}
/*			
			context.move_to (x, y);
			context.line_to (xConnect, yConnect);
			context.stroke ();
//			Works for non inverts only.
*/
		}
		
		context.set_matrix (oldMatrix);
	}
}
