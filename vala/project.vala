/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: project.vala
 *   
 *   Copyright Ashley Newson 2012
 */

public errordomain ProjectLoadError {
	/**
	 * The file being loaded is not a project file.
	 */
	NOT_PROJECT,
	/**
	 * The user has cancelled loading (possibly for security).
	 */
	CANCEL,
	/**
	 * File could not be openned or is invalid.
	 */
	FILE,
	/**
	 * The data within the file is erroneous.
	 */
	LOAD
}


/**
 * Container for a circuit design.
 * 
 * Stores the custom component definitions, root component details,
 * and manages initiation of simulation/validation tasks.
 */
public class Project {
	/**
	 * All projects which the application is currently handling.
	 */
	private static Project[] projects;
	private static int projectCount = 0;
	private bool _pluginsAllowed = false;
	public bool pluginsAllowed {
		set {
			_pluginsAllowed = value;
		}
		get {
			if (_pluginsAllowed == true) {
				return true;
			}
			if (Module.supported() == false) {
				BasicDialog.error (
					null, "Error: Plugin components are not supported on your host system, and cannot be loaded.");
				_pluginsAllowed = false;
			}
			if (BasicDialog.ask_proceed (
					null,
					"Warning:\nYou are about to load one or more plugin components. Plugin components can expand the capabilities of SmartSim, but allow the execution of arbitrary code. Plugins may contain viruses or other malware, so only open projects and plugins that you fully trust. SmartSim and its developers are not responsible for any damage which results from the use of third party plugins. Allow plugins at your own risk.",
					"Allow Plugins", "Cancel Loading") == Gtk.ResponseType.OK) {
				_pluginsAllowed = true;
			} else {
				_pluginsAllowed = false;
			}
			return _pluginsAllowed;
		}
	}
	
	/**
	 * Whether or not the project's circuit is being simulated.
	 */
	public bool running;
	
	/**
	 * Adds //project// to the static //projects// array.
	 */
	public static void register (Project project) {
		int position;
		position = projects.length;
		projects += project;
		project.myID = position;
		
		stdout.printf ("Registered project %i\n", position);
	}
	
	/**
	 * Removes //project// from the static //projects// array.
	 */
	public static void unregister (Project project) {
		Project[] tempArray = {};
		int position;
		int newID = 0;
		position = project.myID;
		
		for (int i = 0; i < projects.length; i ++) {
			if (i != position) {
				projects[i].myID = newID;
				tempArray += projects[i];
				newID ++;
			}
		}
		
		projects = tempArray;
		
		stdout.printf ("Unregistered project %i\n", position);
		
		if (projects.length == 0) {
			stdout.printf ("No more open projects!\n");
		}
	}
	
	public static void clean_up () {
		Project[] newProjects = {};
		int newID = 0;
		
		foreach (Project project in projects) {
			if (DesignerWindow.project_has_windows(project)) {
				newProjects += project;
				project.myID = newID;
				newID++;
			} else {
				project.destroy_all_windows (); //Hidden window destroyer
				
				stdout.printf ("Unregistered project %i (no windows)\n", project.myID);
			}
		}
		
		projects = newProjects;
	}
	
	
	
	/**
	 * Contains all the custom components which the user has designed.
	 */
	public CustomComponentDef[] customComponentDefs;
	/**
	 * Contains all the plugin components which the user has loaded.
	 */
	public PluginComponentDef[] pluginComponentDefs;
	public PluginComponentManager[] pluginComponentManagers;
	/**
	 * The custom component which is the root component.
	 */
	public CustomComponentDef rootComponent;
	
	public int myID;
	public string name {private set; public get;}
	public string description;
	/**
	 * Contains all the designers associated with this project.
	 */
	private Designer[] designers;
	private int designerCount = 0;
	
	public string filename;
	
	/**
	 * Creates a new project and registers it.
	 */
	public Project () {
		stdout.printf ("New Project Created\n");
		Project.register (this);
		Project.projectCount ++;
		name = "Project " + Project.projectCount.to_string ();
		description = "";
		filename = "";
	}
	
	public Project.load (string filename) throws ProjectLoadError {
		stdout.printf ("Loading Project...\n");
		Project.register (this);
		Project.projectCount ++;
		name = "Project " + Project.projectCount.to_string ();
		description = "";
		this.filename = filename;
		
		Xml.Doc* xmldoc;
		Xml.Node* xmlroot;
		Xml.Node* xmlnode;
		
		xmldoc = Xml.Parser.parse_file (filename);
		
		if (xmldoc == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", filename);
			stdout.printf ("File inaccessible.\n");
			throw new ProjectLoadError.FILE ("File inaccessible");
		}
		
		xmlroot = xmldoc->get_root_element ();
		
		if (xmlroot == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n",filename);
			stdout.printf ("File is empty.\n");
			throw new ProjectLoadError.FILE ("File empty");
		}
		
		if (xmlroot->name != "project") {
			stdout.printf ("Error loading info xml file \"%s\".\n", filename);
			stdout.printf ("Wanted \"project\" info, but got \"%s\"\n", xmlroot->name);
			throw new ProjectLoadError.NOT_PROJECT ("Wanted \"project\" info, but got \"" + xmlroot->name + "\"");
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
			case "component":
			{
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
							
					string componentFilename = xmldata->content;
							
					stdout.printf ("Absolute path of file \"%s\" is \"%s\"\n", componentFilename, absolute_filename(componentFilename));
							
					CustomComponentDef component = load_component (absolute_filename(componentFilename));
							
					if (component != null) {
						for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
							switch (xmlattr->name) {
							case "root":
								if (bool.parse(xmlattr->children->content)) {
									set_root_component (component);
								}
								break;
							}
						}
					}
				}
			}
			break;
			case "plugin":
			{
				if (pluginsAllowed == false) {
					throw new ProjectLoadError.CANCEL ("User disallowed plugins.");
				}
				
				for (Xml.Node* xmldata = xmlnode->children; xmldata != null; xmldata = xmldata->next) {
					if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
						continue;
					}
					
					string componentFilename = xmldata->content;
					
					stdout.printf ("Absolute path of file \"%s\" is \"%s\"\n", componentFilename, absolute_filename(componentFilename));
					
					PluginComponentDef component = load_plugin_component (absolute_filename(componentFilename), Config.resourcesDir + "plugins/" + componentFilename);
					
					if (component == null) {
						throw new ProjectLoadError.FILE ("Error loading plugin from file \"" + componentFilename + "\".");
					}
				}
			}
			break;
			}
		}
	}
	
	~Project () {
		stdout.printf ("Project Destroyed.\n");
	}
	
	/**
	 * Creates and returns a new designer, associating it with the
	 * DesignerWindow //window//.
	 */
	public Designer new_designer (DesignerWindow window) {
		Designer designer;
		designer = new Designer (window, this);
		register_designer (designer);
		designerCount ++;
		
		return designer;
	}
	
	/**
	 * Creates and returns a new custom component within the project.
	 */
	public CustomComponentDef new_component () {
		CustomComponentDef newComponent = new CustomComponentDef (this);
		
		int idAdd = 1;
		while (true) {
			newComponent.name = "Untitled Component " + (idAdd).to_string();
			if (resolve_def_name(newComponent.name) == null) {
				break;
			} else {
				idAdd++;
			}
		}
		CustomComponentDef[] newCustomComponentDefs = customComponentDefs;
		newCustomComponentDefs += newComponent;
		customComponentDefs = newCustomComponentDefs;
		update_custom_menus ();
		update_plugin_menus ();
		return newComponent;
	}
	
	/**
	 * If a window is associated with a file with filename //filename//,
	 * make it visible and return 1, else return 0.
	 */
	public int reopen_window_from_file (string filename) {
		foreach (Designer designer in designers) {
			if (designer.window.componentFileName == filename) {
				if (designer.window != null) {
					if (!designer.window.visible) {
						designer.window.show_all ();
						DesignerWindow.register (designer.window);
						update_custom_menus ();
						update_plugin_menus ();
					}
					designer.window.present ();
					return 1;
				}
			}
		}
		
		foreach (CustomComponentDef customComponentDef in customComponentDefs) {
			if (customComponentDef.filename == filename) {
				DesignerWindow window = new DesignerWindow.with_existing_component (this, customComponentDef);
				window.present ();
			}
		}
		
		return 0;
	}
	
	/**
	 * If a window is associated with the custom component
	 * //customComponentDef//, make it visible and return 1, else
	 * return 0.
	 */
	public int reopen_window_from_component (CustomComponentDef customComponentDef) {
		foreach (Designer designer in designers) {
			if (designer.customComponentDef == customComponentDef) {
				if (designer.window != null) {
					if (!designer.window.visible) {
						designer.window.show_all ();
						DesignerWindow.register (designer.window);
						update_custom_menus ();
						update_plugin_menus ();
					}
					designer.window.present ();
					return 1;
				}
			}
		}
		
		if (customComponentDef in customComponentDefs) {
			DesignerWindow window = new DesignerWindow.with_existing_component (this, customComponentDef);
			window.present ();
		}
		
		return 0;
	}
	
	public int destroy_all_windows () {
		foreach (Designer designer in designers) {
			if (designer.window != null) {
				designer.window.force_destroy_window ();
			}
		}
		
		return 0;
	}
	
	/**
	 * Loads and returns a component from the file //fileName//. Returns
	 * null on failure.
	 */
	public CustomComponentDef? load_component (string fileName) {
		CustomComponentDef newComponent;
		
		try {
			newComponent = new CustomComponentDef.from_file (fileName, this);
			CustomComponentDef[] newCustomComponentDefs = customComponentDefs;
			newCustomComponentDefs += newComponent;
			customComponentDefs = newCustomComponentDefs;
			update_custom_menus ();
			update_plugin_menus ();
		} catch (ComponentDefLoadError error) {
			BasicDialog.error (null, "Could not load custom component: \n" + error.message);
			
			newComponent = null;
		} catch (CustomComponentDefLoadError error) {
			BasicDialog.error (null, "Could not load custom component: \n" + error.message);
			
			newComponent = null;
		}
		return newComponent;
	}
	
	/**
	 * Loads and returns a plugin component from the file //fileName//.
	 * Returns null on failure.
	 */
	public PluginComponentDef? load_plugin_component (string filename, string? altFilename = null) {
		PluginComponentDef newComponent = null;
		PluginComponentManager newManager = null;
		
		foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
			if (pluginComponentManager.filename == filename) {
				BasicDialog.error (null, "The plugin component with filename \"" + filename + "\" is already loaded in this project.\n");
				return null;
			}
		}
		
		// Check if it is already loaded globally.
		newManager = PluginComponentManager.from_filename (filename);
		if (newManager == null && altFilename != null) {
			newManager = PluginComponentManager.from_filename (altFilename);
		}
		if (newManager != null) {
			newComponent = newManager.pluginComponentDef;
			PluginComponentDef[] newPluginComponentDefs = pluginComponentDefs;
			PluginComponentManager[] newPluginComponentManagers = pluginComponentManagers;
			newPluginComponentDefs += newComponent;
			newPluginComponentManagers += newManager;
			pluginComponentDefs = newPluginComponentDefs;
			pluginComponentManagers = newPluginComponentManagers;
			update_plugin_menus ();
			return newComponent;
		}
		
		try {
			newManager = new PluginComponentManager.from_file (filename, this);
			newComponent = newManager.pluginComponentDef;
			PluginComponentDef[] newPluginComponentDefs = pluginComponentDefs;
			PluginComponentManager[] newPluginComponentManagers = pluginComponentManagers;
			newPluginComponentDefs += newComponent;
			newPluginComponentManagers += newManager;
			pluginComponentDefs = newPluginComponentDefs;
			pluginComponentManagers = newPluginComponentManagers;
			update_plugin_menus ();
		} catch (ComponentDefLoadError error) {
			if (error is ComponentDefLoadError.FILE && altFilename != null) {
				newComponent = load_plugin_component (altFilename);
				if (newComponent == null) {
					BasicDialog.error (null, "Could not load local plugin component: \n" + error.message);
				}
			} else {
				BasicDialog.error (null, "Could not load shared plugin component: \n" + error.message);
			}
		} catch (PluginComponentDefLoadError error) {
			if (altFilename == null) {
				BasicDialog.error (null, "Could not load shared plugin component: \n" + error.message);
			} else {
				BasicDialog.error (null, "Could not load local plugin component: \n" + error.message);
			}
		}
		return newComponent;
	}
	
	/**
	 * Returns the ComponentDef with the name //name//, be it a built-in
	 * or custom component.
	 */
	public ComponentDef? resolve_def_name (string name) {
		foreach (ComponentDef componentDef in Core.standardComponentDefs) {
			if (componentDef.name.down() == name.down()) {
				return componentDef;
			}
		}
		foreach (ComponentDef componentDef in customComponentDefs) {
			if (componentDef.name.down() == name.down()) {
				return componentDef;
			}
		}
		foreach (ComponentDef componentDef in pluginComponentDefs) {
			if (componentDef.name.down() == name.down()) {
				return componentDef;
			}
		}
		
		return null;
	}
	
	public CustomComponentDef? get_default_component () {
		if (rootComponent != null) {
			return rootComponent;
		} else if (customComponentDefs.length > 0) {
			return customComponentDefs[customComponentDefs.length-1];
		} else {
			return null;
		}
	}
	
	public void update_error_modes (bool error) {
		foreach (Designer designer in designers) {
			if (designer.window != null) {
				designer.window.update_error_mode (error);
			}
		}
	}
	
	/**
	 * Makes all associated windows update their menus listing
	 * custom components.
	 */
	public void update_custom_menus () {
		DesignerWindow[] designerWindows = DesignerWindow.get_project_windows(this);
		foreach (DesignerWindow designerWindow in designerWindows) {
			designerWindow.update_custom_menu ();
		}
	}
	
	public void update_plugin_menus () {
		DesignerWindow[] designerWindows = DesignerWindow.get_project_windows(this);
		foreach (DesignerWindow designerWindow in designerWindows) {
			designerWindow.update_plugin_menu ();
		}
	}
	
	public void update_titles () {
		foreach (Designer designer in designers) {
			if (designer.window != null) {
				designer.window.update_title ();
			}
		}
	}
	
	/**
	 * Checks the validity of the circuit and opens a message dialog to
	 * provide information about the validity of the circuit.
	 * Returns a CompiledCircuit which has been told to validate.
	 * Returns null if there is no root component.
	 */
	public CompiledCircuit? validate () {
		CompiledCircuit compiledCircuit;
		
		if (rootComponent == null) {
			stderr.printf ("Cannot validate circuit. Root component unknown.\n");
			
			BasicDialog.error (null, "You must first specify a root component before you can validate your circuit.");
			
			update_error_modes (false);
			
			return null;
		}
		
		compiledCircuit = new CompiledCircuit (this, rootComponent);
		
		compiledCircuit.check_validity();
		
		if (compiledCircuit.errorOccurred) {
			stdout.printf ("Circuit failed validation check.\n");
			
			BasicDialog.warning (null, "Circuit failed validation:\n" + compiledCircuit.errorMessage + "\nNote: Unused components can still cause errors.");
			
			update_error_modes (true);
		}
		
		if (compiledCircuit.warningOccurred) {
			stdout.printf ("Circuit failed validation check.\n");
			
			BasicDialog.warning (null, "Warning:\n" + compiledCircuit.warningMessage + "\nNote: Unused components can still cause errors.");
			
			update_error_modes (false);
		}
		
		if (!compiledCircuit.errorOccurred && !compiledCircuit.warningOccurred) {
			BasicDialog.information (null, "Circuit has passed validation without any errors or warnings.");
			
			update_error_modes (false);
		}
		
		return compiledCircuit;
	}
	
	/**
	 * Starts the simulation of the circuit and if necessary opens a
	 * message dialog to show any errors or warnings. Validates first.
	 * Returns a CompiledCircuit which has been used for the simulation.
	 * Returns null if there is no root component.
	 */
	public CompiledCircuit? run (bool? startNow = true) {
		CompiledCircuit compiledCircuit;
		
		stdout.printf ("Checking whether Root Component is known...\n");
		
		if (rootComponent == null) {
			stderr.printf ("Cannot run circuit. Root component unknown.\n");
			
			BasicDialog.error (null, "You must first specify a root component before you can validate your circuit.");
			
			update_error_modes (false);
			
			return null;
		}
		
		stdout.printf ("Root component is \"%s\".\n", rootComponent.name);
		
		compiledCircuit = new CompiledCircuit (this, rootComponent);
		
		stdout.printf ("Validating...\n");
		
		if (compiledCircuit.check_validity() != 0) {
			stdout.printf ("Circuit failed validation check.\n");
			
			BasicDialog.error (null, "Circuit failed validation:\n" + compiledCircuit.errorMessage + "\nNote: Unused components can still cause errors.");
			
			update_error_modes (true);
			
			return null;
		}
		
		stdout.printf ("Validated.\n");
		stdout.printf ("Compiling...\n");
		
		compiledCircuit.compile ();
		
		if (compiledCircuit.errorOccurred) {
			BasicDialog.error (null, "Circuit appeared to be valid, but failed to compile:\n" + compiledCircuit.errorMessage);
			
			update_error_modes (true);
			
			return null;
		}
		
		if (compiledCircuit.warningOccurred) {
			BasicDialog.error (null, "Compiled successfully, but there are some warnings:\n" + compiledCircuit.warningMessage);
			
			update_error_modes (false);
		}
		
		update_error_modes (false);
		
		stdout.printf ("Compiled.\n");
		
		SimulatorWindow simulatorWindow = new SimulatorWindow (compiledCircuit);
		
		stdout.printf ("Running Circuit...\n");
		
		running = true;
		
		if (startNow) {
			simulatorWindow.run (); 
		}
		
		return compiledCircuit;
	}
	
	/**
	 * Sets the root component for the simulation to //rootComponent//.
	 */
	public void set_root_component (CustomComponentDef rootComponent) {
		stdout.printf ("Set root component to \"%s\"\n", rootComponent.name);
		this.rootComponent = rootComponent;
	}
	
	public int save (string filename) {
		string errorMessage = "";
		
		foreach (CustomComponentDef customComponentDef in customComponentDefs) {
			CustomComponentDef[] componentChain = customComponentDef.validate_dependencies({});
			if (componentChain != null) {
				errorMessage += "Circuit failed cyclic dependency test. Failed ancestry:\n";
				foreach (CustomComponentDef chainComponent in componentChain) {
					errorMessage += "  " + chainComponent.name + ".";
				}
				errorMessage += "\n";
				break;
			}
		}
		
		if (errorMessage != "") {
			BasicDialog.error (null, "Could not save project:\n" + errorMessage);
			
			return 1;
		}
		
		foreach (Designer designer in designers) {
			if (designer.customComponentDef.filename == "") {
				designer.window.present ();
				
				BasicDialog.information (null, "You must save \"" + designer.customComponentDef.name + "\" before the project is saved.");
			}
			
			designer.window.save_component (false);
			
			if (designer.customComponentDef.filename == "") {
				BasicDialog.warning (null, "The project has not been saved. (Component not saved.)");
				
				return 2;
			}
		}
		
		stdout.printf ("Saving Project \"%s\" to \"%s\"\n", name, filename);
		
		Xml.TextWriter xmlWriter = new Xml.TextWriter.filename (filename);
		
		xmlWriter.set_indent (true);
		xmlWriter.set_indent_string ("\t");
		
		xmlWriter.start_document ();
		xmlWriter.start_element ("project");
		
		xmlWriter.start_element ("metadata");
//		xmlWriter.start_element ("date");
//		xmlWriter.write_attribute ("modtime", (new DateTime.now_utc()).to_string());
//		xmlWriter.end_element ();
		xmlWriter.start_element ("version");
		xmlWriter.write_attribute ("smartsim", Core.shortVersionString);
		xmlWriter.end_element ();
		xmlWriter.end_element ();
		
		stdout.printf ("Saving description data...\n");
		
		xmlWriter.write_element ("name", (name != null) ? name : "Untitled");
		xmlWriter.write_element ("description", description);
		
		stdout.printf ("Saving component list...\n");
		
		save_component_list (xmlWriter);
		
		xmlWriter.end_element ();
		xmlWriter.end_document ();
		xmlWriter.flush ();
		
		stdout.printf ("Saving complete...\n");
		
		return 0;
	}
	
	public void save_component_list (Xml.TextWriter xmlWriter) {
		CustomComponentDef[] unsavedComponents = {};
		CustomComponentDef[] saveLoadOrder = {};
		
		foreach (CustomComponentDef customComponentDef in customComponentDefs) {
			customComponentDef.update_immediate_dependencies ();
			unsavedComponents += customComponentDef;
		}
		
		bool stillWorking = true;
		
		while (stillWorking) {
			CustomComponentDef[] justAdded = {};
			
			stillWorking = false;
			
			foreach (CustomComponentDef customComponentDef in unsavedComponents) {
				if (customComponentDef.immediateDependencies.length == 0) {
					saveLoadOrder += customComponentDef;
					justAdded += customComponentDef;
					stillWorking = true;
				}
			}
			
			CustomComponentDef[] newUnsavedComponents = {};
			
			foreach (CustomComponentDef customComponentDef in unsavedComponents) {
				foreach (CustomComponentDef removeComponent in justAdded) {
					customComponentDef.remove_immediate_dependency (removeComponent);
				}
				
				if (!(customComponentDef in justAdded)) {
					newUnsavedComponents += customComponentDef;
				}
			}
			
			unsavedComponents = newUnsavedComponents;
		}
		
		foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
			xmlWriter.start_element ("plugin");
			
			stdout.printf ("Relative path of file \"%s\" is \"%s\"\n", pluginComponentManager.filename, relative_filename(pluginComponentManager.filename));
			
			xmlWriter.write_string (relative_filename(pluginComponentManager.filename));
			
			xmlWriter.end_element ();
		}
		
		foreach (CustomComponentDef customComponentDef in saveLoadOrder) {
			xmlWriter.start_element ("component");
			
			if (customComponentDef == rootComponent) {
				xmlWriter.write_attribute ("root", "true");
			}
			
			stdout.printf ("Relative path of file \"%s\" is \"%s\"\n", customComponentDef.filename, relative_filename(customComponentDef.filename));
			
			xmlWriter.write_string (relative_filename(customComponentDef.filename));
			
			xmlWriter.end_element ();
		}
	}
	
	public int remove_component (CustomComponentDef removeComponent) {
		int result = 1;
		CustomComponentDef[] usersOfComponent = component_users (removeComponent);
		
		if (usersOfComponent.length > 0) {
			string usersString = "";
			
			foreach (CustomComponentDef customComponentDef in usersOfComponent) {
				usersString += "  " + customComponentDef.name + "\n";
			}
			
			BasicDialog.error (null, "You cannot remove this component from your project because it is used within one or more other components:\n" + usersString);
			
			return 2;
		}
		
		CustomComponentDef[] newCustomComponentDefs = {};
		
		foreach (CustomComponentDef customComponentDef in customComponentDefs) {
			if (customComponentDef == removeComponent) {
				result = 0;
			} else {
				newCustomComponentDefs += customComponentDef;
			}
		}
		
		customComponentDefs = newCustomComponentDefs;
		
		if (removeComponent == rootComponent) {
			rootComponent = null;
		}
		
		return result;
	}
	
	public int remove_plugin_component (PluginComponentDef removeComponent) {
		int result = 1;
		CustomComponentDef[] usersOfComponent = component_users (removeComponent);
		
		if (usersOfComponent.length > 0) {
			string usersString = "";
			
			foreach (CustomComponentDef customComponentDef in usersOfComponent) {
				usersString += "  " + customComponentDef.name + "\n";
			}
			
			BasicDialog.error (null, "You cannot remove this plugin component from your project because it is used within one or more other components:\n" + usersString);
			
			return 2;
		}
		
		PluginComponentDef[] newPluginComponentDefs = {};
		
		foreach (PluginComponentDef pluginComponentDef in pluginComponentDefs) {
			if (pluginComponentDef == removeComponent) {
				result = 0;
			} else {
				newPluginComponentDefs += pluginComponentDef;
			}
		}
		
		PluginComponentManager[] newPluginComponentManagers = {};
		
		foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
			if (pluginComponentManager.pluginComponentDef == removeComponent) {
				// pluginComponentManager.unload ();
			} else {
				newPluginComponentManagers += pluginComponentManager;
			}
		}
		
		pluginComponentDefs = newPluginComponentDefs;
		// update_plugin_menus ();
		pluginComponentManagers = newPluginComponentManagers;
		
		return result;
	}
	
	public CustomComponentDef[] component_users (ComponentDef usedComponent) {
		CustomComponentDef[] userList = {};
		
		foreach (CustomComponentDef customComponentDef in customComponentDefs) {
			customComponentDef.update_immediate_dependencies (true);
			
			if (usedComponent in customComponentDef.immediateDependencies) {
				userList += customComponentDef;
			}
		}
		
		return userList;
	}
	
	public void configure () {
		PropertySet configuration = new PropertySet ("Project Configuration", "Project configuration");
		
		configuration.add_item (new PropertyItemString ("Name", "Project's name", name));
		
		PropertiesQuery query = new PropertiesQuery ("Project", null, configuration);
		
		query.run ();
		
		name = PropertyItemString.get_data (configuration, "Name");
	}
	
	public string relative_filename (string rawTargetFilename) { //May need to be replaced!
		string targetFilename = rawTargetFilename.replace (GLib.Path.DIR_SEPARATOR_S, "/");
		string projectFilename = filename.replace (GLib.Path.DIR_SEPARATOR_S, "/");
		
		string[] projectDirectories = {};
		string[] targetDirectories = {};
		
		string result = "";
		
		int startIndex = 0;
		int endIndex = 0;
		
		if (!GLib.Path.is_absolute(targetFilename)) {
			return rawTargetFilename;
		}
		
		while (true) { //breaks
			startIndex = endIndex + 1;
			endIndex = projectFilename.index_of ("/", startIndex);
			if (endIndex == -1) {
				break;
			} else {
				projectDirectories += projectFilename.slice (startIndex, endIndex);
			}
		}
		
		startIndex = 0;
		endIndex = 0;
		
		while (true) { //breaks
			startIndex = endIndex + 1;
			endIndex = targetFilename.index_of ("/", startIndex);
			if (endIndex == -1) {
				break;
			} else {
				targetDirectories += targetFilename.slice (startIndex, endIndex);
			}
		}
		
		int commonCount;
		
		for (commonCount = 0; commonCount < projectDirectories.length; commonCount++) {
			if (projectDirectories[commonCount] != targetDirectories[commonCount]) {
				break;
			}
		}
		
		for (int i = commonCount; i < projectDirectories.length; i++) {
			result += "../"; //Is there a const for ".."?
		}
		
		for (int i = commonCount; i < targetDirectories.length; i++) {
			result += targetDirectories[i] + "/"; //Is there a const for ".."?
		}
		
		result += GLib.Path.get_basename (targetFilename);
		
		return result;
	}
	
	public string absolute_filename (string targetFilename) { //May need to be replaced!
		string result = "";
		
		if (GLib.Path.is_absolute(targetFilename)) {
			return targetFilename;
		}
		
		result += GLib.Path.get_dirname (filename) + GLib.Path.DIR_SEPARATOR_S;
		result += targetFilename.replace ("/", GLib.Path.DIR_SEPARATOR_S);
		
		return result;
	}
	
	/**
	 * Registers //designer// with this project.
	 * Adds it to the //designers// array.
	 */
	public void register_designer (Designer designer) {
		int position;
		position = designers.length;
		designers += designer;
		designer.myID = position;
		
		stdout.printf ("Registered designer %i\n", position);
	}
	
	/**
	 * Unregisters //designer// with this project.
	 * Removes it from the //designers// array.
	 */
	public void unregister_designer (Designer designer) {
		Designer[] tempArray = {};
		int position;
		int newID = 0;
		position = designer.myID;
		
		for (int i = 0; i < designers.length; i ++) {
			if (i != position) {
				designers[i].myID = newID;
				tempArray += designers[i];
				newID ++;
			}
		}
		
		designers = tempArray;
		
		stdout.printf ("Unregistered designer %i\n", position);
		
		if (designers.length == 0) {
			stdout.printf ("No more open designers!\n");
		}
	}
}
