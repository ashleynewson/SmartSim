/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: plugincomponentmanager.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * Manager and loader for a plugin component.
 * 
 * A PluginComponentManager is used to load a component from a shared
 * object / library file, DLL, etc. They greatly expand the capabilities
 * of SmartSim, but can potentially run malicious code.
 */
public class PluginComponentManager {
	/**
	 * A reference to the main program itself.
	 */
	public Module mainProgram = Module.open (null, 0);
	/**
	 * The GModule used to load the plug-in
	 */
	public Module module = null;
	public string filename = null;
	public string name = null;
	// private Type defType;
	// private Type stateType;
	// /**
	//  * The plugin of type //defType// which is given the task of
	//  * implementing the def's functions.
	//  */
	// private PluginComponentInterface plugin;
	public weak Project project;
	public PluginComponentDef pluginComponentDef;
	// private delegate Type get_type_delegate ();
	private delegate bool init_delegate (PluginComponentManager manager);
	private delegate PluginComponentDef get_def_delegate ();
	
	// private delegate void extra_render_delegate (Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst);
	// private delegate void extra_validate_delegate (CustomComponentDef[] componentChain, ComponentInst? componentInst);
	// private delegate void add_properties (PropertySet queryProperty, PropertySet configurationProperty);
	// private delegate void get_properties (PropertySet queryProperty, out PropertySet configurationProperty);
	// private delegate void load_properties (Xml.Node* xmlnode, out PropertySet configurationProperty);
	// private delegate void save_properties (Xml.TextWriter xmlWriter, PropertySet configurationProperty);
	// private delegate void configure_inst (ComponentInst componentInst, bool firstLoad = false);
	// private delegate void compile_component (CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry);
	// private delegate void create_information (CircuitInformation circuitInformation);
	
	
	/**
	 * Loads a PluginComponentDef from a file using libxml.
	 */
	public PluginComponentManager.from_file (string infoFilename, Project project) throws ComponentDefLoadError, PluginComponentDefLoadError {
		this.filename = infoFilename;
		
		this.project = project;
		
		try {
			load (infoFilename);
		} catch (PluginComponentDefLoadError error) {
			throw error;
		}
		
		// try {
		// 	load_from_file (infoFilename);
		// } catch (ComponentDefLoadError error) {
		// 	throw error;
		// } catch (PluginComponentDefLoadError error) {
		// 	throw error;
		// }
		
		if (project.resolve_def_name(name) != null) {
			throw new PluginComponentDefLoadError.NAME_CONFLICT ("A component with the name \"" + name + "\" already exists. Rename the component which is already open using the customiser dialog, accessible via the component menu.");
		}
	}
	
	/**
	 * Loads a component from the file //infoFilename//, using libxml.
	 */
	private int load (string infoFilename) throws ComponentDefLoadError, PluginComponentDefLoadError {
		string libraryPath = null;
		
		stdout.printf ("Loading plugin component specific data from \"%s\"\n", infoFilename);
		
		Xml.Doc* xmldoc;
		Xml.Node* xmlroot;
		Xml.Node* xmlnode;
		
		xmldoc = Xml.Parser.parse_file (infoFilename);
		
		if (xmldoc == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File inaccessible.\n");
			throw new ComponentDefLoadError.FILE ("File inaccessible: \"" + infoFilename + "\"");
		}
		
		xmlroot = xmldoc->get_root_element ();
		
		if (xmlroot == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("File is empty.\n");
			throw new ComponentDefLoadError.FILE ("File empty: \"" + infoFilename + "\"");
		}
		
		if (xmlroot->name != "plugin_component") {
			stdout.printf ("Error loading info xml file \"%s\".\n", infoFilename);
			stdout.printf ("Wanted \"plugin_component\" info, but got \"%s\"\n", xmlroot->name);
			throw new PluginComponentDefLoadError.NOT_PLUGIN ("Wanted \"plugin_component\" info, but got \"" + xmlroot->name + "\": \"" + infoFilename + "\"");
		}
		
		for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
			if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
				continue;
			}
			
			switch (xmlnode->name) {
			case "name":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					this.name = xmldata->content;
				}
			}
			break;
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
			libraryPath = Config.resourcesDir + "plugins/" + this.name.down();
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
						libraryPath = Config.resourcesDir + "plugins/" + this.name.down();
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
	
	private void load_library (string libraryPath) throws PluginComponentDefLoadError {
		string fullLibraryPath = Module.build_path (GLib.Path.get_dirname(libraryPath), GLib.Path.get_basename(libraryPath));
		
		stdout.printf ("Attempting to open module: %s\n", fullLibraryPath);
		
		module = Module.open (fullLibraryPath, ModuleFlags.BIND_LAZY);
		if (module == null) {
			stdout.printf ("Error opening module: %s\n", Module.error());
			throw new PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE ("Library could not be opened: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
		}
		stdout.printf ("Successfully opened module.\n");
		
		// void* get_def_type_pointer;
		// void* get_state_type_pointer;
		void* init_pointer;
		void* get_def_pointer;
		// get_type_delegate get_def_type_function = null;
		// get_type_delegate get_state_type_function = null;
		init_delegate init_function = null;
		get_def_delegate get_def_function = null;
		
		if (module.symbol("plugin_component_init", out init_pointer)) {
			if (init_pointer != null) {
				init_function = (init_delegate) init_pointer;
				if (init_function(this) == false) {
					stdout.printf ("Error initialising plugin: Plugin init function reported failure.\n");
					throw new PluginComponentDefLoadError.INIT_ERROR ("Plugin init function reported failure: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
				}
			}
		}
		
		if (module.symbol("plugin_component_get_def", out get_def_pointer)) {
			if (get_def_pointer != null) {
				get_def_function = (get_def_delegate) get_def_pointer;
			}
		}
		if (get_def_function != null) {
			stdout.printf ("Error initialising plugin: Could not get component definition function.\n");
			throw new PluginComponentDefLoadError.LIBRARY_NOT_COMPATIBLE ("Could not get component definition function: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
		} else {
			pluginComponentDef = get_def_function ();
			if (pluginComponentDef == null) {
				stdout.printf ("Error initialising plugin: Failure getting component definition.\n");
				throw new PluginComponentDefLoadError.INIT_ERROR ("Failure getting component definition: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
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
}
