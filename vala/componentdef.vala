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
 *   Filename: componentdef.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * ComponentDef load from file errors.
 */
public errordomain ComponentDefLoadError {
	/**
	 * The file being loaded is not a component file.
	 */
	NOT_COMPONENT,
	/**
	 * File could not be openned or is invalid.
	 */
	FILE,
	/**
	 * The data within the file is erroneous.
	 */
	LOAD,
	/**
	 * Loading was cancelled (e.g. due to version).
	 */
	CANCEL
}



/**
 * Definition of a component
 * 
 * Used to describe a component's appearance, compile ComponentStates,
 * and handle special properties held by ComponentInsts.
 */
public abstract class ComponentDef {
	/**
	 * The SVG graphical representation to use in priority to a box
	 * diagram.
	 */
	public Graphic graphic;
	/**
	 * The filename to use if the graphic has not been changed.
	 */
	protected string graphicReferenceFilename = null;
	
	public string name = "";
	public string description = "";
	/**
	 * Icon to display inside the DesignerWindow toolbar.
	 */
	public string iconFilename = "";
	public string label = "";
	
	/**
	 * Describe the pin configurations.
	 */
	public PinDef[] pinDefs;
	
	public int rightBound;
	public int downBound;
	public int leftBound;
	public int upBound;
	
	public int backgroundAlpha = 0;
	public int backgroundRed = 255;
	public int backgroundGreen = 255;
	public int backgroundBlue = 255;
	
	public double backgroundAlphaF = 0;
	public double backgroundRedF = 1;
	public double backgroundGreenF = 1;
	public double backgroundBlueF = 1;
	
	public bool drawBox = true;
	
	public string filename = "";
	
	// /**
	//  * Creates a new ComponentDef.
	//  */
	// public ComponentDef () {
		
	// }

	/**
	 * Loads a component definition from a file.
	 */
	public void load_from_file (string infoFilename) throws ComponentDefLoadError, CustomComponentDefLoadError , PluginComponentDefLoadError {
		if (infoFilename == "") {
			stdout.printf ("Defining component later\n");
			return;
		}
		
		stdout.printf ("Loading component info \"%s\"\n", infoFilename);
		
		Xml.Doc* xmldoc;
		Xml.Node* xmlroot;
		Xml.Node* xmlnode;
		
		xmldoc = Xml.Parser.parse_file (infoFilename);
		
		if (xmldoc == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File inaccessible.\n");
			throw new ComponentDefLoadError.FILE ("File inaccessible");
		}
		
		xmlroot = xmldoc->get_root_element ();
		
		if (xmlroot == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File is empty.\n");
			throw new ComponentDefLoadError.FILE ("File empty");
		}
		
		if (this is CustomComponentDef) {
			if (xmlroot->name != "custom_component") {
				stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
				stdout.printf ("Wanted \"custom_component\" info, but got \"%s\"\n", xmlroot->name);
				throw new CustomComponentDefLoadError.NOT_CUSTOM ("Wanted \"custom_component\" info, but got \"" + xmlroot->name + "\"");
			}
		} else if (this is PluginComponentDef) {
			if (xmlroot->name != "plugin_component") {
				stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
				stdout.printf ("Wanted \"plugin_component\" info, but got \"%s\"\n", xmlroot->name);
				throw new PluginComponentDefLoadError.NOT_PLUGIN ("Wanted \"plugin_component\" info, but got \"" + xmlroot->name + "\"");
			}
		} else {
			if (xmlroot->name != "component") {
				stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
				stdout.printf ("Wanted \"component\" info, but got \"%s\"\n", xmlroot->name);
				throw new ComponentDefLoadError.NOT_COMPONENT ("Wanted \"component\" info, but got \"" + xmlroot->name + "\"");
			}
		}
		
		PinDef[] pinDefs = {};
		
		for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
			if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
				continue;
			}
			
			switch (xmlnode->name) {
			case "metadata":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmldata->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					
					switch (xmldata->name) {
					case "version":
					{
						for (Xml.Attr* xmlattr = xmldata->properties; xmlattr != null; xmlattr = xmlattr->next) {
							switch (xmlattr->name) {
							case "smartsim":
								if (Core.compare_versions(xmlattr->children->content) == VersionComparison.GREATER) {
									if (Core.version_ignored("Component File: \"" + infoFilename + "\"") == false) {
										throw new ComponentDefLoadError.CANCEL ("SmartSim version of component is higher than running version.");
									}
								}
								break;
							}
						}
					}
					break;
					}
				}
			}
			break;
			case "name":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					name = xmldata->content;
				}
			}
			break;
			case "description":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					description = xmldata->content;
				}
			}
			break;
			case "icon":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					iconFilename = xmldata->content;
				}
			}
			break;
			case "graphic":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					
					this.graphicReferenceFilename = xmldata->content;
					try {
						this.graphic = new Graphic.from_file (Core.absolute_filename(xmldata->content, GLib.Path.get_dirname(infoFilename)));
					} catch {
						try {
							this.graphic = new Graphic.from_file (Config.resourcesDir + "components/graphics/" + xmldata->content);
						} catch (GraphicLoadError error) {
							stdout.printf ("Cannot load graphic \"" + xmldata->content + "\"\n");
						}
					}
				}
			}
			break;
			case "label":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					label = xmldata->content;
				}
			}
			break;
			case "bound":
			{
				for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
					switch (xmlattr->name) {
					case "right":
						rightBound = int.parse(xmlattr->children->content);
						break;
					case "down":
						downBound = int.parse(xmlattr->children->content);
						break;
					case "left":
						leftBound = int.parse(xmlattr->children->content);
						break;
					case "up":
						upBound = int.parse(xmlattr->children->content);
						break;
					case "drawbox":
						drawBox = bool.parse(xmlattr->children->content);
						break;
					}
							
				}
			}
			break;
			case "color":
			case "colour":
			{
				for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
					switch (xmlattr->name) {
					case "a":
						backgroundAlpha = int.parse(xmlattr->children->content);
						backgroundAlphaF = (double)backgroundAlpha / 255.0;
						break;
					case "r":
						backgroundRed = int.parse(xmlattr->children->content);
						backgroundRedF = (double)backgroundRed / 255.0;
						break;
					case "g":
						backgroundGreen = int.parse(xmlattr->children->content);
						backgroundGreenF = (double)backgroundGreen / 255.0;
						break;
					case "b":
						backgroundBlue = int.parse(xmlattr->children->content);
						backgroundBlueF = (double)backgroundBlue / 255.0;
						break;
					}
				}
			}
			break;
			case "pin":
			{
				PinDef pinDef = new PinDef.load (xmlnode);
						
				pinDefs += pinDef;
			}
			break;
			}
		}
		
		delete xmldoc;
		
		this.pinDefs = pinDefs;
		
		return;
	}
	
	/**
	 * Render the component's image, excluding pins. Either renders the
	 * graphic or box diagram.
	 */
	public void render (Cairo.Context context, Direction direction = Direction.RIGHT, bool flipped = false, ComponentInst? componentInst = null, bool colourBackground = true) {
		if (graphic != null) {
			Cairo.Matrix oldMatrix;
			
			oldMatrix = context.get_matrix ();
			
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
			
			if (flipped) {
				context.scale (1.0, -1.0);
			}
			
			graphic.render (context);
			
			context.set_matrix (oldMatrix);
		} else {
			render_box (context, direction, flipped, colourBackground, componentInst);
		}
		
		extra_render (context, direction, flipped, componentInst);
	}
	
	/**
	 * Renders the box diagram. Used when there is no graphic.
	 */
	public void render_box (Cairo.Context context, Direction direction, bool flipped, bool colourBackground, ComponentInst? componentInst) {
		Cairo.Matrix oldMatrix;
		Cairo.Matrix oldMatrix2;
		Cairo.TextExtents textExtents;
		
		int rightBound;
		int downBound;
		int leftBound;
		int upBound;
		
		if (componentInst == null) {
			rightBound = this.rightBound;
			downBound = this.downBound;
			leftBound = this.leftBound;
			upBound = this.upBound;
		} else {
			rightBound = componentInst.rightBound;
			downBound = componentInst.downBound;
			leftBound = componentInst.leftBound;
			upBound = componentInst.upBound;
		}
		
		oldMatrix = context.get_matrix ();
		
		context.set_source_rgba (0, 0, 0, 1);
		
//		context.set_font_size (16);
//		context.text_extents (label, out textExtents);
//		context.move_to (-textExtents.width/2, +textExtents.height/2);
//		context.show_text (label);
		
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
		
		if (flipped) {
			context.scale (1.0, -1.0);
		}
		
		context.set_line_width (2);
		
		if (drawBox) {
			if (leftBound - rightBound == 0 && upBound - downBound == 0) {
				context.set_line_width (5);
				Cairo.LineCap oldLineCap = context.get_line_cap ();
				context.set_line_cap (Cairo.LineCap.ROUND);
				context.move_to (rightBound, downBound);
				context.line_to (rightBound, downBound);
				context.stroke ();
				context.set_line_cap (oldLineCap);
				//context.rectangle (rightBound - 5, downBound - 5, 5, 5);
				context.stroke ();
			} else {
				if (colourBackground) {
					context.set_source_rgba (backgroundRedF, backgroundGreenF, backgroundBlueF, backgroundAlphaF);
					context.rectangle (leftBound, upBound, rightBound - leftBound, downBound - upBound);
					context.fill ();
					context.stroke ();
				}
				context.set_source_rgba (0, 0, 0, 1);
				context.rectangle (leftBound, upBound, rightBound - leftBound, downBound - upBound);
				context.stroke ();
			}
		}
		
		oldMatrix2 = context.get_matrix ();
		context.set_matrix (oldMatrix);
		
		context.set_font_size (16);
		context.text_extents (label, out textExtents);
		context.move_to (-textExtents.width/2, +textExtents.height/2);
		context.show_text (label);
		
		context.set_matrix (oldMatrix2);
		
		context.set_line_width (1);
		
		for (int i = 0; i < pinDefs.length; i++) {
			if (componentInst != null) {
				if (i >= componentInst.pinInsts.length) {
					break;
				}
				if (!componentInst.pinInsts[i].show) {
					continue;
				}
			}
			
			PinDef pinDef = pinDefs[i];
			switch (pinDef.labelType) {
			case PinDef.LabelType.TEXT:
			case PinDef.LabelType.TEXTBAR:
				oldMatrix2 = context.get_matrix ();
					
				if (componentInst == null) {
					context.translate (pinDef.xLabel, pinDef.yLabel);
				} else {
					context.translate (componentInst.pinInsts[i].xLabel, componentInst.pinInsts[i].yLabel);
				}
				if (flipped) {
					context.scale (1.0, -1.0);
				}
				context.rotate (-angle);
					
				context.set_font_size (8);
				context.text_extents (pinDef.label, out textExtents);
				context.move_to (-textExtents.width/2, +textExtents.height/2);
				context.show_text (pinDef.label);
					
				if (pinDef.labelType == PinDef.LabelType.TEXTBAR) {
					context.move_to (-textExtents.width/2, -1 - textExtents.height/2);
					context.line_to ( textExtents.width/2, -1 - textExtents.height/2);
					context.stroke ();
				}
					
				context.set_matrix (oldMatrix2);
				break;
			case PinDef.LabelType.CLOCK:
				oldMatrix2 = context.get_matrix ();
					
				if (componentInst == null) {
					context.translate (pinDef.x, pinDef.y);
				} else {
					context.translate (componentInst.pinInsts[i].x[0], componentInst.pinInsts[i].y[0]);
				}
					
				double angle2 = 0;
					
				switch (pinDef.direction) {
				case Direction.RIGHT:
					angle2 = 0;
					break;
				case Direction.DOWN:
					angle2 = Math.PI * 0.5;
					break;
				case Direction.LEFT:
					angle2 = Math.PI;
					break;
				case Direction.UP:
					angle2 = Math.PI * 1.5;
					break;
				}
				context.rotate (angle2);
					
				context.move_to (0, -6);
				context.line_to (-9, 0);
				context.line_to (0,  6);
				context.stroke ();
					
				context.set_matrix (oldMatrix2);
				break;
			}
		}
		
		context.set_matrix (oldMatrix);
	}
	
	/**
	 * Some ComponentDefs do extra rendering.
	 */
	public virtual void extra_render (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
		//Do nothing.
	}
	
	/**
	 * Some ComponentDefs do extra validation. CURRENTLY UNUSED.
	 */
	public virtual void extra_validate (Project project, CustomComponentDef[] componentChain, ComponentInst? componentInst) {
		//Do nothing.
	}
	
	/**
	 * Some ComponentInsts need to hold extra information which they
	 * cannot process. This helps create a PropertySet for a 
	 * PropertiesQuery.
	 */
	public virtual void add_properties (PropertySet queryProperty, PropertySet configurationProperty) {
	}
	
	/**
	 * Some ComponentInsts need to hold extra information which they
	 * cannot process. This is used to extract the user input from a 
	 * PropertiesQuery stored in a PropertySet into another PropertySet.
	 */
	public virtual void get_properties (PropertySet queryProperty, out PropertySet configurationProperty) {
		configurationProperty = new PropertySet (name + " configuration");
	}
	
	/**
	 * Some ComponentInsts need to hold extra information which they
	 * cannot process. This loads properties from a file using libxml.
	 */
	public virtual void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty) {
		configurationProperty = new PropertySet (name + " configuration");
	}
	
	/**
	 * Some ComponentInsts need to hold extra information which they
	 * cannot process. This saves properties to a file using libxml.
	 */
	public virtual void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
		//Do nothing.
	}
	
	public virtual void configure_inst (ComponentInst componentInst, bool firstLoad = false) {
		//Do nothing.
	}
	
	/**
	 * Low level compilation. Handled differently for each ComponentDef
	 * sub class.
	 */
	public abstract void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry);
	
	public virtual void create_information (CircuitInformation circuitInformation) {
		circuitInformation.count_component (this);
	}
}
