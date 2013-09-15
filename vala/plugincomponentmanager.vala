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
	public weak Project project;
	public PluginComponentDef pluginComponentDef;
	private delegate bool init_delegate (PluginComponentManager manager);
	private delegate PluginComponentDef? get_def_delegate (string infoFilename);
	
	/**
	 * A reference to standard in for use by the plugin
	 */
	public unowned FileStream stdinFileStream;
	/**
	 * A reference to standard out for use by the plugin
	 */
	public unowned FileStream stdoutFileStream;
	/**
	 * A reference to standard err for use by the plugin
	 */
	public unowned FileStream stderrFileStream;
	
	
	/**
	 * Loads a PluginComponentDef from a file using libxml.
	 */
	public PluginComponentManager.from_file (string infoFilename, Project project) throws ComponentDefLoadError, PluginComponentDefLoadError 
{
		this.filename = infoFilename;
		
		this.project = project;
		
		this.stdinFileStream = stdin;
		this.stdoutFileStream = stdout;
		this.stderrFileStream = stderr;
		
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
		
		if (project.resolve_def_name(pluginComponentDef.name) != null) {
			throw new PluginComponentDefLoadError.NAME_CONFLICT ("A component with the name \"" + name + "\" already exists. Rename the component which is already open using the customiser dialog, accessible via the component menu.");
		}
		
		pluginComponentDef.manager = this;
	}
	
    ~PluginComponentManager () {
		stdout.printf ("Plugin \"%s\" (\"%s\") Unloaded.\n", name, filename);
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
			stdout.printf ("Unable to open module: %s\n", Module.error());
			throw new PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE ("Library could not be opened: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
		}
		stdout.printf ("Successfully opened module.\n");
		
		void* init_pointer = null;
		void* get_def_pointer = null;
		init_delegate init_function = null;
		get_def_delegate get_def_function = null;
		
		if (module.symbol("plugin_component_init", out init_pointer)) {
			if (init_pointer != null) {
				init_function = (init_delegate) init_pointer;
				if (init_function(this) == false) {
					stdout.printf ("Error initialising plugin: Plugin init function reported failure.\n");
					throw new PluginComponentDefLoadError.INIT_ERROR ("Plugin init function reported failure: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
				}
			} else {
				stdout.printf ("Got null plugin_component_init function.\n");
			}
		}
		if (init_pointer == null) {
			stdout.printf ("Plugin has no init function (plugin_component_init).\n");
		}
		
		if (module.symbol("plugin_component_get_def", out get_def_pointer)) {
			if (get_def_pointer != null) {
				get_def_function = (get_def_delegate) get_def_pointer;
			}
		}
		if (get_def_pointer == null) {
			stdout.printf ("Error initialising plugin: Could not get component definition function.\n");
			throw new PluginComponentDefLoadError.LIBRARY_NOT_COMPATIBLE ("Could not get component definition function: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
		} else {
			pluginComponentDef = get_def_function (this.filename);
			if (pluginComponentDef == null) {
				stdout.printf ("Error initialising plugin: Failure getting component definition.\n");
				throw new PluginComponentDefLoadError.INIT_ERROR ("Failure getting component definition: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
			}
		}
	}
	
	public void print_info (string text) {
		stdout.printf ("Plugin \"%s\" (\"%s\") Info:\n\t%s\n", name, filename, text);
	}
	
	public void print_error (string text) {
		stdout.printf ("Plugin \"%s\" (\"%s\") Error:\n\t%s\n", name, filename, text);
	}
	
	/*
	 * The external code needs to be unreferenced and freed before unloading the module while deconstructing.
	 * It cannot be assumed that the order in which things are dereferenced is the one needed.
	 */
	public void unload () {
		pluginComponentDef.manager = null;
		pluginComponentDef = null;
	}
}
