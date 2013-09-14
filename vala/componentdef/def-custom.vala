/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/custom.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * CustomComponentDef load from file errors.
 */
public errordomain CustomComponentDefLoadError {
	NOT_CUSTOM,
	MISSING_DEPENDENCY,
	NAME_CONFLICT,
	INVALID
}

/**
 * Definition of a custom component.
 * 
 * A CustomComponentDef is the design and specification of
 * a user defined component, which can be included in another component.
 */
public class CustomComponentDef : ComponentDef {
	/**
	 * All the components contained within the design.
	 */
	public ComponentInst[] componentInsts;
	/**
	 * All the wires contained within the design.
	 */
	public WireInst[] wireInsts;
	/**
	 * All the annotations contained within the design.
	 */
	public Annotation[] annotations;
	/**
	 * The project which this component belongs to.
	 */
	private weak Project project;
	
	public CustomComponentDef[] immediateDependencies;
	
	/**
	 * Creates a new custom component, associated with //project//.
	 */
	public CustomComponentDef (Project project) {
		base ();
		
		this.project = project;
	}
	
	/**
	 * Loads a CustomComponentDef from a file using libxml.
	 */
	public CustomComponentDef.from_file (string infoFilename, Project project) throws ComponentDefLoadError, CustomComponentDefLoadError {
		try {
			load_from_file (infoFilename);
		} catch (ComponentDefLoadError error) {
			throw error;
		} catch (CustomComponentDefLoadError error) {
			throw error;
		} catch (PluginComponentDefLoadError error) {
			throw new CustomComponentDefLoadError.NOT_CUSTOM ("Got Plugin.");
		}
		
		if (project.resolve_def_name(name) != null) {
			throw new CustomComponentDefLoadError.NAME_CONFLICT ("A component with the name \"" + name + "\" already exists. Rename the component which is already open using the customiser dialog, accessible via the component menu.");
		}
		
		this.project = project;
		
		try {
			load (infoFilename);
		} catch (CustomComponentDefLoadError error) {
			throw error;
		}
		
		filename = infoFilename;
	}
	
	public void get_design_bounds (out int right, out int down, out int left, out int up) {
		right = int.MIN;
		down = int.MIN;
		left = int.MAX;
		up = int.MAX;
		
		foreach (ComponentInst componentInst in componentInsts) {
			int currentRight;
			int currentDown;
			int currentLeft;
			int currentUp;
			
			componentInst.absolute_bounds (out currentRight, out currentDown, out currentLeft, out currentUp);
			
			if (currentRight > right) {
				right = currentRight;
			}
			if (currentDown > down) {
				down = currentDown;
			}
			if (currentLeft < left) {
				left = currentLeft;
			}
			if (currentUp < up) {
				up = currentUp;
			}
		}
		
		foreach (WireInst wireInst in wireInsts) {
			foreach (Path path in wireInst.paths) {
				if (path.lines.length == 0) {
					continue;
				}
				
				if (path.lines[0].x1 > right) {
					right = path.lines[0].x1;
				}
				if (path.lines[0].y1 > down) {
					down = path.lines[0].y1;
				}
				if (path.lines[0].x1 < left) {
					left = path.lines[0].x1;
				}
				if (path.lines[0].y1 < up) {
					up = path.lines[0].y1;
				}
				
				foreach (Path.Line line in path.lines) {
					if (line.x2 > right) {
						right = line.x2;
					}
					if (line.y2 > down) {
						down = line.y2;
					}
					if (line.x2 < left) {
						left = line.x2;
					}
					if (line.y2 < up) {
						up = line.y2;
					}
				}
			}
			
			if (wireInst.interfaceTag != null) {
				if (wireInst.interfaceTag.rightBound > right) {
					right = wireInst.interfaceTag.rightBound;
				}
				if (wireInst.interfaceTag.downBound > down) {
					down = wireInst.interfaceTag.downBound;
				}
				if (wireInst.interfaceTag.leftBound < left) {
					left = wireInst.interfaceTag.leftBound;
				}
				if (wireInst.interfaceTag.upBound < up) {
					up = wireInst.interfaceTag.upBound;
				}
			}
		}
		
		foreach (Annotation annotation in annotations) {
			int currentRight = annotation.xPosition + annotation.width;
			int currentDown = annotation.yPosition + annotation.height;
			int currentLeft = annotation.xPosition;
			int currentUp = annotation.yPosition;
			
			if (currentRight > right) {
				right = currentRight;
			}
			if (currentDown > down) {
				down = currentDown;
			}
			if (currentLeft < left) {
				left = currentLeft;
			}
			if (currentUp < up) {
				up = currentUp;
			}
		}
		
		if (right < left || down < up) {
			right = 0;
			down = 0;
			left = 0;
			up = 0;
		}
	}
	
	/**
	 * Renders the design of the circuitry.
	 * If //showHints// is true, design-aiding elements will be
	 * displayed.
	 * If //showErrors// is true, errors will be highlighted.
	 */
	public void render_insts (Cairo.Context context, bool showHints = false, bool showErrors = false, bool colourBackgrounds = true) {
		foreach (Annotation annotation in annotations) {
			annotation.render (context, showHints);
		}
		foreach (ComponentInst componentInst in componentInsts) {
			componentInst.render (context, showHints, showErrors, colourBackgrounds);
		}
		foreach (WireInst wireInst in wireInsts) {
			wireInst.render (context, showHints);
		}
	}
	
	/**
	 * Add a new ComponentInst of type //componentDef//, at
	 * (//x//, //y//), facing //direction// to the design.
	 */
	public ComponentInst add_componentInst (ComponentDef componentDef, int x, int y, Direction direction) {
		ComponentInst componentInst = new ComponentInst (componentDef, x, y, direction);
		ComponentInst[] newComponentInsts = componentInsts;
		newComponentInsts += componentInst;
		componentInsts = newComponentInsts;
		stdout.printf ("Added component\n");
		return componentInst;
	}
	
	/**
	 * Add a new Annotation at (//x//, //y//), with text //text// of
	 * font size //fontSize// to the design.
	 */
	public void add_annotation (int x, int y, string text, double fontSize = 12) {
		Annotation annotation = new Annotation (x, y, text, fontSize);
		Annotation[] newAnnotations = annotations;
		newAnnotations += annotation;
		annotations = newAnnotations;
		stdout.printf ("Added annotation\n");
	}
	
	/**
	 * Adds a new wire to the design and returns it.
	 */
	public WireInst add_wire () {
		WireInst wireInst = new WireInst ();
		WireInst[] newWireInsts = wireInsts;
		newWireInsts += wireInst;
		wireInsts = newWireInsts;
		stdout.printf ("Added wire\n");
		return wireInst;
	}
	
	/**
	 * Deletes any selected components.
	 */
	public void delete_selected_components () {
		ComponentInst[] newComponentInsts = {};
		foreach (ComponentInst componentInst in componentInsts) {
			if (componentInst.selected) {
				componentInst.detatch_all ();
				stdout.printf ("Component deleted\n");
			} else {
				newComponentInsts += componentInst;
			}
		}
		componentInsts = newComponentInsts;
	}
	
	/**
	 * Deletes any selected wires.
	 */
	public void delete_selected_wires () {
		WireInst[] newWireInsts = {};
		foreach (WireInst wireInst in wireInsts) {
			if (wireInst.selected) {
				wireInst.disconnect_components ();
				stdout.printf ("Wire deleted\n");
			} else {
				newWireInsts += wireInst;
			}
		}
		wireInsts = newWireInsts;
	}
	
	/**
	 * Deletes any selected annotations.
	 */
	public void delete_selected_annotations () {
		Annotation[] newAnnotations = {};
		foreach (Annotation annotation in annotations) {
			if (annotation.selected) {
				stdout.printf ("Annotation deleted\n");
			} else {
				newAnnotations += annotation;
			}
		}
		annotations = newAnnotations;
	}
	
	/**
	 * Assigns new unique IDs to components and wires.
	 */
	public void update_ids () {
		stdout.printf ("Updating Component IDs\n");
		
		for (int i = 0; i < componentInsts.length; i ++) {
			componentInsts[i].myID = i;
		}
		
		stdout.printf ("Updating Wire IDs\n");
		
		for (int i = 0; i < wireInsts.length; i ++) {
			wireInsts[i].myID = i;
		}
	}
	
	/**
	 * Recursive function to check for any cyclic dependencies. Returns
	 * an ancestry up to the point of failure if there is a cyclic
	 * dependency, else returns null.
	 */
	public CustomComponentDef[]? validate_dependencies (CustomComponentDef[] componentChain) {
		CustomComponentDef[] newComponentChain
		= new CustomComponentDef[componentChain.length + 1];
		
		for (int i = 0; i < componentChain.length; i++) {
			newComponentChain[i] = componentChain[i];
		}
		newComponentChain[newComponentChain.length-1] = this;
		
		foreach (CustomComponentDef chainPart in componentChain) {
			if (chainPart == this) {
				return newComponentChain;
			}
		}
		
		foreach (ComponentInst componentInst in componentInsts) {
			if (componentInst.componentDef is CustomComponentDef) {
				CustomComponentDef[] result;
				result = (componentInst.componentDef as CustomComponentDef).validate_dependencies (newComponentChain);
				
				if (result != null) {
					return result;
				}
			}
		}
		
		return null;
	}
	
	/**
	 * Checks that all ComponentInsts are adequately connected to wires.
	 * Returns the number of erroneous components.
	 */
	public int validate_pins () {
		int errorCount = 0;
		
		foreach (ComponentInst componentInst in componentInsts) {
			foreach (PinInst pinInst in componentInst.pinInsts) {
				if (pinInst.validate_connections() == 1) {
					componentInst.errorMark = true;
					errorCount++;
					break;
				}
			}
		}
		
		return errorCount;
	}
	
	/**
	 * Checks that all pins map to an interface tag. Return 0 on success
	 * or 1 on failure.
	 */
	public int validate_interfaces () {
		for (int i = 0; i < pinDefs.length; i++) {
			if (resolve_tag_id(i) == null) {
				return 1;
			}
		}
		
		return 0;
	}
	
	/**
	 * Check for any components sharing the same centre. Return the
	 * number of erroneous components.
	 */
	public int validate_overlaps () {
		int errorCount = 0;
		
		for (int i1 = 0; i1 < componentInsts.length; i1++) {
			ComponentInst componentInst1 = componentInsts[i1];
			for (int i2 = i1+1; i2 < componentInsts.length; i2++) {
				ComponentInst componentInst2 = componentInsts[i2];
				if (componentInst1.xPosition == componentInst2.xPosition
					&& componentInst1.yPosition == componentInst2.yPosition) {
					stdout.printf ("Found overlaping components!\n");
					componentInst1.errorMark = true;
					componentInst2.errorMark = true;
					errorCount++;
				}
			}
		}
		
		return errorCount;
	}
	
	/**
	 * Loads a component from the file //infoFilename//, using libxml.
	 */
	public int load (string infoFilename) throws CustomComponentDefLoadError.MISSING_DEPENDENCY, CustomComponentDefLoadError.INVALID {
		if (infoFilename == "") {
			stdout.printf ("Defining component later\n");
			return 0;
		}
		
		stdout.printf ("Loading custom component specific data from \"%s\"\n", infoFilename);
		
		Xml.Doc* xmldoc;
		Xml.Node* xmlroot;
		Xml.Node* xmlnode;
		
		xmldoc = Xml.Parser.parse_file (infoFilename);
		
		if (xmldoc == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File inaccessible.\n");
			return 1;
		}
		
		xmlroot = xmldoc->get_root_element ();
		
		if (xmlroot == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File is empty.\n");
			return 1;
		}
		
		if (xmlroot->name != "custom_component") {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("Wanted \"custom_component\" info, but got \"%s\"\n", xmlroot->name);
			return 1;
		}
		
		ComponentInst[] newComponentInsts = {};
		WireInst[] newWireInsts = {};
		Annotation[] newAnnotations = {};
		
		for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
			if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
				continue;
			}
			
			switch (xmlnode->name) {
			case "wire":
			{
				WireInst newWireInst = new WireInst.load (xmlnode);
						
				newWireInsts += newWireInst;
			}
			break;
			case "component":
			{
				ComponentInst newComponentInst;
						
				try {
					newComponentInst = new ComponentInst.load (xmlnode, project, newWireInsts);
					newComponentInsts += newComponentInst;
				} catch (ComponentInstLoadError.INVALID error) {
					stderr.printf ("Error adding new component: %s\n", error.message);
					throw new CustomComponentDefLoadError.INVALID (error.message);
				} catch (ComponentInstLoadError.MISSING_DEF error) {
					stderr.printf ("Error adding new component: %s\n", error.message);
					throw new CustomComponentDefLoadError.MISSING_DEPENDENCY (error.message);
				}
						
			}
			break;
			case "annotation":
			{
				Annotation newAnnotation;
						
				try {
					newAnnotation = new Annotation.load (xmlnode);
					newAnnotations += newAnnotation;
				} catch (AnnotationLoadError.EMPTY error) {
					stderr.printf ("Error adding new annotation: %s\n", error.message);
				}
						
			}
			break;
			}
		}
		
		delete xmldoc;
		
		wireInsts = newWireInsts;
		componentInsts = newComponentInsts;
		annotations = newAnnotations;
		
		return 0;
	}
	
	/**
	 * Saves the ComponentInst to the file //fileName//, using libxml.
	 */
	public int save (string fileName) {
		stdout.printf ("Saving Component \"%s\" to \"%s\"\n", name, fileName);
		
		update_ids ();
		
		Xml.TextWriter xmlWriter = new Xml.TextWriter.filename (fileName);
		
		xmlWriter.set_indent (true);
		xmlWriter.set_indent_string ("\t");
		
		xmlWriter.start_document ();
		xmlWriter.start_element ("custom_component");
		
		stdout.printf ("Saving description data...\n");
		
		xmlWriter.start_element ("metadata");
//		xmlWriter.start_element ("date");
//		xmlWriter.write_attribute ("modtime", (new DateTime.now_utc()).to_string());
//		xmlWriter.end_element ();
		xmlWriter.start_element ("version");
		xmlWriter.write_attribute ("smartsim", Core.shortVersionString);
		xmlWriter.end_element ();
		xmlWriter.end_element ();
		
		xmlWriter.write_element ("name", (name != null) ? name : "Untitled");
		xmlWriter.write_element ("description", description);
		xmlWriter.write_element ("label", label);
		
		xmlWriter.start_element ("bound");
		xmlWriter.write_attribute ("right", rightBound.to_string());
		xmlWriter.write_attribute ("down", downBound.to_string());
		xmlWriter.write_attribute ("left", leftBound.to_string());
		xmlWriter.write_attribute ("up", upBound.to_string());
		xmlWriter.end_element ();
		
		xmlWriter.start_element ("colour");
		xmlWriter.write_attribute ("a", backgroundAlpha.to_string());
		xmlWriter.write_attribute ("r", backgroundRed.to_string());
		xmlWriter.write_attribute ("g", backgroundGreen.to_string());
		xmlWriter.write_attribute ("b", backgroundBlue.to_string());
		xmlWriter.end_element ();
		
		stdout.printf ("Saving pin data...\n");
		
		for (int i = 0; i < pinDefs.length; i ++) {
			pinDefs[i].save (xmlWriter, i);
		}
		
		stdout.printf ("Saving wire data...\n");
		
		for (int i = 0; i < wireInsts.length; i ++) {
			wireInsts[i].save (xmlWriter);
		}
		
		stdout.printf ("Saving component data...\n");
		
		for (int i = 0; i < componentInsts.length; i ++) {
			componentInsts[i].save (xmlWriter);
		}
		
		
		stdout.printf ("Saving annotation data...\n");
		
		for (int i = 0; i < annotations.length; i ++) {
			annotations[i].save (xmlWriter);
		}
		
		xmlWriter.end_element ();
		xmlWriter.end_document ();
		xmlWriter.flush ();
		
		stdout.printf ("Saving complete...\n");
		
		return 0;
	}
	
	/**
	 * Recursive method to compile custom components. Compiles to
	 * //compiledCircuit//. Compile the //componentInst// representing
	 * the custom component. The high level connections are stored in
	 * //connections//. The sub-components are part of the ancestry
	 * //ancestry//.
	 */
	public override void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
		WireState[] localWireStates = {};
		ComponentInst[] newAncestry = {};
		
		if (componentInst != null) {
			foreach (ComponentInst prevComponentInst in ancestry) {
				newAncestry += prevComponentInst;
			}
			newAncestry += componentInst;
		}
		
		foreach (WireInst wireInst in wireInsts) {
			WireState wireState = compiledCircuit.compile_wire (wireInst, connections, newAncestry);
			localWireStates += wireState;
		}
		
		foreach (ComponentInst childComponentInst in componentInsts) {
			childComponentInst.compile_component (compiledCircuit, localWireStates, newAncestry);
		}
	}
	
	/**
	 * Returns the ComponentInst at (//x//, //y//). Returns null if
	 * there isn't one.
	 */
	public ComponentInst? find_inst (int x, int y) {
		foreach (ComponentInst componentInst in componentInsts) {
			if (componentInst.find(x, y) == 1) {
				return componentInst;
			}
		}
		return null;
	}
	
	/**
	 * Returns the interface tag with the given ID. Returns null if
	 * there isn't one.
	 */
	public Tag? resolve_tag_id (int tagID) {
		foreach (WireInst wireInst in wireInsts) {
			if (wireInst.interfaceTag != null) {
				if (wireInst.interfaceTag.pinid == tagID) {
					return wireInst.interfaceTag;
				}
			}
		}
		
		return null;
	}
	
	/**
	 * Returns the lowest unused interface tag ID in the design.
	 */
	public int new_tag_id () {
		int tagID = 0;
		bool keepGoing = true;
		
		while (keepGoing) {
			keepGoing = false;
			foreach (WireInst wireInst in wireInsts) {
				if (wireInst.interfaceTag != null) {
					if (wireInst.interfaceTag.pinid == tagID) {
						keepGoing = true;
						tagID++;
					}
				}
			}
		}
		
		return tagID;
	}
	
	/**
	 * Return the number of interface tags.
	 */
	public int count_tags () {
		int tagCount = 0;
		
		foreach (WireInst wireInst in wireInsts) {
			if (wireInst.interfaceTag != null) {
				tagCount++;
			}
		}
		
		return tagCount;
	}
	
	public override void create_information (CircuitInformation circuitInformation) {
		circuitInformation.count_component (this);
		
		foreach (ComponentInst componentInst in componentInsts) {
			componentInst.componentDef.create_information (circuitInformation);
		}
	}
	
	public void update_immediate_dependencies () {
		CustomComponentDef[] newImmediateDependencies = {};
		
		foreach (ComponentInst componentInst in componentInsts) {
			if (componentInst.componentDef is CustomComponentDef) {
				CustomComponentDef customComponentDef = componentInst.componentDef as CustomComponentDef;
				
				if (!(customComponentDef in immediateDependencies)) {
					newImmediateDependencies += customComponentDef;
				}
			}
		}
		
		immediateDependencies = newImmediateDependencies;
	}
	
	public void remove_immediate_dependency (CustomComponentDef removeComponent) {
		CustomComponentDef[] newImmediateDependencies = {};
		
		foreach (CustomComponentDef customComponentDef in immediateDependencies) {
			if (customComponentDef != removeComponent) {
				newImmediateDependencies += customComponentDef;
			}
		}
		
		immediateDependencies = newImmediateDependencies;
	}
	
	~CustomComponentDef () {
		stdout.printf ("Custom Component Destroyed\n");
	}
}
