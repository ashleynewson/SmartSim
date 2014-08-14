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
 *   Filename: pininst.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * An instance of a pin on a ComponentInst.
 * 
 * Stores information about a pin and its connections.
 */
public class PinInst {
	/**
	 * x positions pins extend from in a pin array.
	 */
	public int[] x;
	/**
	 * y positions pins extend from in a pin array.
	 */
	public int[] y;
	/**
	 * x positions pins extend to in a pin array.
	 */
	public int[] xConnect;
	/**
	 * y positions pins extend to in a pin array.
	 */
	public int[] yConnect;
	/**
	 * The x position of the pin's box design label.
	 */
	public int xLabel;
	/**
	 * The y position of the pin's box design label.
	 */
	public int yLabel;
	/**
	 * The wire pins in an array connect to.
	 */
	public WireInst[] wireInsts;
	/**
	 * Whether pins in an array are inverted.
	 */
	public bool[] invert;
	/**
	 * What PinDef the pin is based off.
	 */
	public PinDef pinDef;
	/**
	 * How many pins there are in the array. Set to 1 if not an array.
	 */
	public int arraySize;
	/**
	 * The smallest //x// in a pin array.
	 */
	public int xMin;
	/**
	 * The greatest //x// in a pin array.
	 */
	public int xMax;
	/**
	 * The smallest //y// in a pin array.
	 */
	public int yMin;
	/**
	 * The greatest //y// in a pin array.
	 */
	public int yMax;
	
	public bool show;
	
	
	/**
	 * Creates a pin or an array of pins from the PinDef //pinDef//.
	 */
	public PinInst (PinDef pinDef, int arraySize = 1) {
		x.resize (arraySize);
		y.resize (arraySize);
		xConnect.resize (arraySize);
		yConnect.resize (arraySize);
		invert.resize (arraySize);
		wireInsts.resize (arraySize);
		
		for (int i = 0; i < arraySize; i ++) {
			x[i] = pinDef.x;
			y[i] = pinDef.y;
			xConnect[i] = pinDef.xConnect;
			yConnect[i] = pinDef.yConnect;
			invert[i] = false;
			wireInsts[i] = null;
		}
		
		xLabel = pinDef.xLabel;
		yLabel = pinDef.yLabel;
		
		this.pinDef = pinDef;
		this.arraySize = arraySize;
		
		this.show = pinDef.showDefault;
		
		if (arraySize != 0) {
			update_spacing ();
		}
	}
	
	/**
	 * Increases the number of pins in an array by 1.
	 */
	public int append () {
		x.resize (arraySize + 1);
		y.resize (arraySize + 1);
		xConnect.resize (arraySize + 1);
		yConnect.resize (arraySize + 1);
		invert.resize (arraySize + 1);
		wireInsts.resize (arraySize + 1);
		
		x[arraySize] = pinDef.x;
		y[arraySize] = pinDef.y;
		xConnect[arraySize] = pinDef.xConnect;
		yConnect[arraySize] = pinDef.yConnect;
		invert[arraySize] = false;
		wireInsts[arraySize] = null;
		
		arraySize++;
		
		update_spacing ();
		
		return (arraySize - 1);
	}
	
	/**
	 * Calculates the best spacing for pins in an array.
	 */
	public void update_spacing () {
		if (pinDef.minSpace == 0 && pinDef.idealSpace == 0 || arraySize == 1) {
			for (int i = 0; i < arraySize; i ++) {
				xConnect[i] = pinDef.xConnect;
				yConnect[i] = pinDef.yConnect;
				x[i] = pinDef.x;
				y[i] = pinDef.y;
			}
		} else {
			float space = (float)pinDef.idealSpace / (arraySize - 1);
			
			if (space < pinDef.minSpace) {
				space = pinDef.minSpace;
			}
			
			switch (pinDef.direction) {
				case Direction.RIGHT:
				case Direction.LEFT:
					float yStart = (float)pinDef.y - (space * (arraySize - 1) / 2);
					for (int i = 0; i < arraySize; i ++) {
						xConnect[i] = pinDef.xConnect;
						yConnect[i] = (int)(yStart + (space * i));
						x[i] = pinDef.x;
						y[i] = (int)(yStart + (space * i));
					}
					
					xMin = pinDef.x;
					xMax = pinDef.x;
					yMin = pinDef.y - (int)(space * (arraySize - 1) / 2);
					yMax = pinDef.y + (int)(space * (arraySize - 1) / 2);
					break;
				case Direction.DOWN:
				case Direction.UP:
					float xStart = (float)pinDef.x - (space * (arraySize - 1) / 2);
					for (int i = 0; i < arraySize; i ++) {
						xConnect[i] = (int)(xStart + (space * i));
						yConnect[i] = pinDef.yConnect;
						x[i] = (int)(xStart + (space * i));
						y[i] = pinDef.y;
					}
					
					xMin = pinDef.x - (int)(space * (arraySize - 1) / 2);
					xMax = pinDef.x + (int)(space * (arraySize - 1) / 2);
					yMin = pinDef.y;
					yMax = pinDef.y;
					break;
			}
		}
	}
	
	public void update_position () {
		for (int i = 0; i < arraySize; i++) {
			switch (pinDef.direction) {
				case Direction.RIGHT:
					xConnect[i] = x[i] + pinDef.length;
					xLabel = x[i] - 10;
					break;
				case Direction.DOWN:
					yConnect[i] = y[i] + pinDef.length;
					yLabel = y[i] - 10;
					break;
				case Direction.LEFT:
					xConnect[i] = x[i] - pinDef.length;
					xLabel = x[i] + 10;
					break;
				case Direction.UP:
					yConnect[i] = y[i] - pinDef.length;
					yLabel = y[i] + 10;
					break;
			}
		}
	}
	
	/**
	 * Inverts any pins at (//x//, //y//).
	 */
	public void try_invert (int x, int y) {
		for (int i = 0; i < arraySize; i ++) {
			if (x == xConnect[i] && y == yConnect[i]) {
				invert[i] = invert[i] ? false : true; //Invert value
			}
		}
	}
	
	/**
	 * Connects any pins at (//x//, //y//) to //wireInst//.
	 * //componentInst// is the parent component of the pin.
	 */
	public bool try_connect (int x, int y, WireInst wireInst, ComponentInst componentInst) {
		for (int i = 0; i < arraySize; i ++) {
			if (wireInsts[i] == null) {
				if (x == xConnect[i] && y == yConnect[i]) {
					wireInsts[i] = wireInst;
					int xAbsolute;
					int yAbsolute;
					componentInst.absolute_position (x, y, out xAbsolute, out yAbsolute);
					wireInst.register_component (componentInst, xAbsolute, yAbsolute);
//					wireInst.register_component (componentInst, x + componentInst.xPosition, y + componentInst.yPosition);
					stdout.printf ("Connected Component Input\n");
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Disconnects any pins at (//x//, //y//) from wires.
	 * //componentInst// is the parent component of the pin.
	 */
	public bool try_disconnect (int x, int y, ComponentInst componentInst) {
		for (int i = 0; i < arraySize; i ++) {
			if (x == xConnect[i] && y == yConnect[i] && wireInsts[i] != null) {
				int xAbsolute;
				int yAbsolute;
				componentInst.absolute_position (x, y, out xAbsolute, out yAbsolute);
				wireInsts[i].unregister_component_xy (componentInst, xAbsolute, yAbsolute);
//				wireInsts[i].unregister_component_xy (componentInst, x + componentInst.xPosition, y + componentInst.yPosition);
				wireInsts[i] = null;
				stdout.printf ("Disconnected Component Input\n");
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Disconnects all pins in the array from wires.
	 * //componentInst// is the parent component of the pin.
	 */
	public bool disconnect (ComponentInst componentInst) {
		for (int i = 0; i < arraySize; i ++) {
			if (wireInsts[i] != null) {
				int xAbsolute;
				int yAbsolute;
				componentInst.absolute_position (xConnect[i], yConnect[i], out xAbsolute, out yAbsolute);
				wireInsts[i].unregister_component_xy (componentInst, xAbsolute, yAbsolute);
				wireInsts[i] = null;
				stdout.printf ("Disconnected Component Input\n");
			}
		}
		
		return false;
	}
	
	/**
	 * Check that all pins that require connections have connections.
	 * Return 0 on pass, 1 on failure.
	 */
	public int validate_connections () {
		if (!pinDef.required) {
			return 0;
		}
		for (int i = 0; i < arraySize; i ++) {
			if (wireInsts[i] == null) {
				return 1;
			}
		}
		return 0;
	}
	
	/**
	 * Render the pins in the array. If //showHints// is true, any
	 * unconnected pins will show in red.
	 */
	public void render (Cairo.Context context, bool showHints) {
		if (!show) {
			return;
		}
		
		for (int i = 0; i < arraySize; i ++) {
			if (wireInsts[i] != null || !showHints) {
				context.set_source_rgb (0, 0, 0);
			} else {
				context.set_source_rgb (1, 0, 0);
			}
			
			Cairo.Matrix oldMatrix;
			
			oldMatrix = context.get_matrix ();
			context.translate (x[i], y[i]);
			
			if (pinDef.direction != Direction.NONE) {
				double angle = 0;
				
				switch (pinDef.direction) {
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
				if (invert[i]) {
					context.move_to (10, 0);
					context.line_to (pinDef.length, 0);
					context.arc (5, 0, 5, 0, Math.PI * 2);
					context.stroke ();
				} else {
					context.move_to (0, 0);
					context.line_to (pinDef.length, 0);
					context.stroke ();
				}
			}
			
			context.set_matrix (oldMatrix);
		}
	}
}
