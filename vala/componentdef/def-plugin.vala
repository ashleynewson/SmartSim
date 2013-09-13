/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentdef/def-plugin.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * PluginComponentDef load from file errors.
 */
public errordomain PluginComponentDefLoadError {
	NOT_PLUGIN,
	INIT_ERROR,
	LIBRARY_NOT_ACCESSIBLE,
	LIBRARY_NOT_COMPATIBLE,
	NAME_CONFLICT,
	INVALID
}

/**
 * Definition of a plugin component.
 * 
 * A PluginComponentDef is used to define and load a component from a
 * shared object file, DLL, etc. They greatly expand the capabilities of
 * SmartSim, but can potentially run malicious code.
 */
public class PluginComponentDef : ComponentDef {
	private static Module mainProgram = Module.open (null);
	/**
	 * The GModule used to load the plug-in
	 */
	private Module module = null;
	// private Type defType;
	// private Type stateType;
	// /**
	//  * The plugin of type //defType// which is given the task of
	//  * implementing the def's functions.
	//  */
	// private PluginComponentInterface plugin;
	private Project project;
	// private delegate Type get_type_delegate ();
	private delegate bool init_delegate (Module mainProgram);
	
	private delegate void extra_render_delegate (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst);
	private delegate void extra_validate_delegate (CustomComponentDef[] componentChain, ComponentInst? componentInst);
	private delegate void add_properties (PropertySet queryProperty, PropertySet configurationProperty);
	private delegate void get_properties (PropertySet queryProperty, out PropertySet configurationProperty);
	private delegate void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty);
	private delegate void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty);
	private delegate void configure_inst (ComponentInst componentInst, bool firstLoad = false);
	private delegate void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry);
	private delegate void create_information (CircuitInformation circuitInformation);
	
	
	/**
	 * Loads a PluginComponentDef from a file using libxml.
	 */
	public PluginComponentDef.from_file (string infoFilename, Project project) throws ComponentDefLoadError, PluginComponentDefLoadError {
		try {
			load_from_file (infoFilename);
		} catch (ComponentDefLoadError error) {
			throw error;
		} catch (PluginComponentDefLoadError error) {
			throw error;
		}
		
		if (project.resolve_def_name(name) != null) {
			throw new CustomComponentDefLoadError.NAME_CONFLICT ("A component with the name \"" + name + "\" already exists. Rename the component which is already open using the customiser dialog, accessible via the component menu.");
		}
		
		this.project = project;
		
		try {
			load (infoFilename);
		} catch (PluginComponentDefLoadError error) {
			throw error;
		}
		
		filename = infoFilename;
	}
	
	/**
	 * Loads a component from the file //infoFilename//, using libxml.
	 */
	public int load (string infoFilename) throws PluginComponentDefLoadError.INIT_ERROR, PluginComponentDefLoadError.INVALID {
		string libraryPath = NULL;
		
		if (infoFilename == "") {
			stdout.printf ("Defining component later\n");
			return 0;
		}
		
		stdout.printf ("Loading plugin component specific data from \"%s\"\n", infoFilename);
		
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
		
		if (xmlroot->name != "plugin_component") {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("Wanted \"plugin_component\" info, but got \"%s\"\n", xmlroot->name);
			return 1;
		}
		
		for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
			if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
				continue;
			}
			
			switch (xmlnode->name) {
			case "library":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					libraryPath = xmldata->content;
				}
			}
			break;
			}
		}
		
		delete xmldoc;
		
		// If a path is given, try to use that plugin, else resort to the resources directory.
		if (libraryPath == null) {
			libraryPath = Config.resourceDir + "plugins/" + this.name.down();
			try {
				load_library (libraryPath);
			} catch (PluginComponentDefLoadError error) {
				throw error;
			}
		} else {
			libraryPath = project.relative_filename (libraryPath);
			try {
				load_library (libraryPath);
			} catch (PluginComponentDefLoadError error) {
				// The path's version was not found, fall back to resources directory.
				if (error is PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE) {
					try {
						libraryPath = Config.resourceDir + "plugins/" + this.name.down();
						load_library (libraryPath);
					} catch (PluginComponentDefLoadError error) {
						throw error;
					}
				} else {
					throw error;
				}
			}
		}
		
		return 0;
	}
	
	public void load_library (string libraryPath) throws PluginComponentDefLoadError {
		string fullLibraryPath = Module.build_path (null, libraryPath);
		
		module = Module.open (fullLibraryPath);
		if (module == null) {
			stdout.printf ("Error opening module: %s\n", Module.error());
			throw new PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE ("Library could not be opened.");
		}
		
		// void* get_def_type_pointer;
		// void* get_state_type_pointer;
		void* init_pointer;
		// get_type_delegate get_def_type_function = null;
		// get_type_delegate get_state_type_function = null;
		init_delegate init_function = null;
		
		if (module.symbol("plugin_component_init", out init_pointer)) {
			if (init_pointer != null) {
				init_function = (init_delegate) init_pointer;
				if (init_function(PluginComponentDef.mainProgram) == false) {
					stdout.printf ("Error initialising module.\n");
					throw new PluginComponentDefLoadError.INIT_ERROR ("Error initialising module.");
				}
			}
		}
		// if (module.symbol("plugin_component_get_def_type", out get_def_type_pointer)) {
		// 	if (get_def_type_pointer != null) {
		// 		get_def_type_function = (get_type_delegate) get_def_type_pointer;
		// 	}
		// }
		// if (module.symbol("plugin_component_get_state_type", out get_state_type_pointer)) {
		// 	if (get_state_type_pointer != null) {
		// 		get_state_type_function = (get_type_delegate) get_state_type_pointer;
		// 	}
		// }
		// if (get_def_type_function == null) {
		// 	stdout.printf ("Error loading module: \"plugin_component_get_def_type\" function not found in module.\n");
		// 	throw new PluginComponentDefLoadError.LIBRARY_NOT_COMPATIBLE ("\"plugin_component_get_def_type\" function not found in module.");
		// }
		// if (get_state_type_function == null) {
		// 	stdout.printf ("Error loading module: \"plugin_component_get_state_type\" function not found in module.\n");
		// 	throw new PluginComponentDefLoadError.LIBRARY_NOT_COMPATIBLE ("\"plugin_component_get_state_type\" function not found in module.");
		// }
	}
	
	public override void extra_render (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
	}
}