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
	private Module module = null;
	private Project project;
	
	/**
	 * Loads a PluginComponentDef from a file using libxml.
	 */
	public PluginComponentDef.from_file (string infoFilename, Project project) throws ComponentDefLoadError, PluginComponentDefLoadError {
		try {
			base.from_file (infoFilename);
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
	public int load (string infoFilename) throws PluginComponentDefLoadError.MISSING_DEPENDENCY, PluginComponentDefLoadError.INVALID {
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
		
		return 0;
	}
}