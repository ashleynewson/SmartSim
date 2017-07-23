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
     * Due to the inability of easily being able to reload plugins,
     * the current system must keep plugins loaded
     */
    private static PluginComponentManager[] pluginComponentManagers = {};

    /**
     * Adds //pluginComponentManager// to the list of loaded managers.
     */
    private static void register(PluginComponentManager pluginComponentManager) {
        int position;
        position = pluginComponentManagers.length;
        pluginComponentManagers += pluginComponentManager;

        stdout.printf("Registered Plugin Component Manager (%i: \"%s\").\n", position, pluginComponentManager.name);
    }

    /**
     * Dereference everything. Only call at program termination.
     */
    public static void unregister_all() {
        /*
         * The order for the unloading of plugins is very important.
         * All references to plugin code must be removed before un linking.
         */

        stdout.printf("Unregistering Plugin Component Managers...\n");

        foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
            pluginComponentManager.unload();
        }
        pluginComponentManagers = null;

        stdout.printf("Unregistered Plugin Component Managers.\n");
    }

    /**
     * Returns a manager which is found with name //name//,
     * or null is none exists.
     */
    public static PluginComponentManager? from_name(string name) {
        foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
            if (pluginComponentManager.name == name) {
                return pluginComponentManager;
            }
        }
        return null;
    }

    /**
     * Returns a manager which is found with filename //filename//,
     * or null is none exists.
     */
    public static PluginComponentManager? from_filename(string filename) {
        foreach (PluginComponentManager pluginComponentManager in pluginComponentManagers) {
            stdout.printf(
                "Comparing component filenames: \n\t\"%s\"\n\t\"%s\"\n",
                Core.absolute_filename(pluginComponentManager.filename),
                Core.absolute_filename(filename)
            );
            if (Core.absolute_filename(pluginComponentManager.filename) == Core.absolute_filename(filename)) {
                return pluginComponentManager;
            }
        }
        return null;
    }


    /**
     * A reference to the main program itself.
     */
    public Module mainProgram = Module.open(null, 0);
    /**
     * The GModule used to load the plug-in
     */
    public Module module = null;
    public string filename = null;
    public string name = null;
    public weak Project project;
    public PluginComponentDef pluginComponentDef;
    private delegate bool init_delegate(PluginComponentManager manager);
    private delegate PluginComponentDef? get_def_delegate(string infoFilename);


    /**
     * Loads a PluginComponentDef from a file using libxml.
     */
    public PluginComponentManager.from_file(string infoFilename, Project project) throws ComponentDefLoadError, PluginComponentDefLoadError
    {
        if (PluginComponentManager.from_filename(infoFilename) != null) {
            stdout.printf("Error initialising plugin: Plugin cannot load twice conflict: \"%s\".\n", infoFilename);
            throw new PluginComponentDefLoadError.NAME_CONFLICT("Plugin cannot load twice: \"" + infoFilename + "\"");
        }

        this.filename = infoFilename;

        this.project = project;

        try {
            load(infoFilename);
        } catch (PluginComponentDefLoadError error) {
            throw error;
        }

        PluginComponentManager.register(this);

        pluginComponentDef.manager = this;
    }

    ~PluginComponentManager() {
        stdout.printf("Plugin \"%s\" (\"%s\") Unloaded.\n", name, filename);
    }

    /**
     * Loads a component from the file //infoFilename//, using libxml.
     */
    private int load(string infoFilename) throws ComponentDefLoadError, PluginComponentDefLoadError {
        string libraryPath = null;
        string builtLibraryPath = null;

        stdout.printf("Loading plugin component specific data from \"%s\"\n", infoFilename);

        Xml.Doc* xmldoc;
        Xml.Node* xmlroot;
        Xml.Node* xmlnode;

        xmldoc = Xml.Parser.parse_file(infoFilename);

        if (xmldoc == null) {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("File inaccessible.\n");
            throw new ComponentDefLoadError.FILE("File inaccessible: \"" + infoFilename + "\"");
        }

        xmlroot = xmldoc->get_root_element();

        if (xmlroot == null) {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("File is empty.\n");
            throw new ComponentDefLoadError.FILE("File empty: \"" + infoFilename + "\"");
        }

        if (xmlroot->name != "plugin_component") {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("Wanted \"plugin_component\" info, but got \"%s\"\n", xmlroot->name);
            throw new PluginComponentDefLoadError.NOT_PLUGIN("Wanted \"plugin_component\" info, but got \"" + xmlroot->name + "\": \"" + infoFilename + "\"");
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

        if (project.resolve_def_name(this.name) != null) {
            throw new PluginComponentDefLoadError.NAME_CONFLICT("A component with the name \"" + name + "\" already exists. Rename the component which is already open (if it is a custom component) using the customiser dialog, accessible via the component menu.");
        }

        if (PluginComponentManager.from_name(this.name) != null) {
            stdout.printf("Error initialising plugin: Plugin name conflict: \"%s\".\n", this.name);
            throw new PluginComponentDefLoadError.NAME_CONFLICT("Plugin name conflict: \"" + this.name + "\"");
        }

        // If a path is given, try to use that plugin, else resort to the resources directory.
        if (libraryPath == null) {
            builtLibraryPath = Config.librariesDir + this.name.down();
            try {
                load_library(builtLibraryPath);
            } catch (PluginComponentDefLoadError error) {
                throw error;
            }
        } else {
            if (GLib.Path.is_absolute(libraryPath) == false) {
                builtLibraryPath = GLib.Path.build_filename(GLib.Path.get_dirname(filename), GLib.Path.get_dirname(libraryPath), GLib.Path.get_basename(libraryPath));
            } else {
                builtLibraryPath = libraryPath;
            }
            try {
                load_library(builtLibraryPath);
            } catch (PluginComponentDefLoadError error) {
                // The path's version was not found, fall back to resources directory.
                if (error is PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE) {
                    try {
                        builtLibraryPath = Config.librariesDir + libraryPath;
                        load_library(builtLibraryPath);
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

    private void load_library(string libraryPath) throws PluginComponentDefLoadError {
        string fullLibraryPath;

        fullLibraryPath = Module.build_path(GLib.Path.get_dirname(libraryPath), GLib.Path.get_basename(libraryPath));

        stdout.printf("Attempting to open module: %s\n", fullLibraryPath);

        module = Module.open(fullLibraryPath, 0);
        if (module == null) {
            stdout.printf("Unable to open module: %s\n", Module.error());
            throw new PluginComponentDefLoadError.LIBRARY_NOT_ACCESSIBLE("Library could not be opened: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
        }
        stdout.printf("Successfully opened module.\n");

        void* init_pointer = null;
        void* get_def_pointer = null;
        unowned init_delegate init_function = null;
        unowned get_def_delegate get_def_function = null;

        if (module.symbol("plugin_component_init", out init_pointer)) {
            if (init_pointer != null) {
                stdout.printf("Initialising plugin... (plugin_component_init).\n");
                init_function = (init_delegate) init_pointer;
                if (init_function(this) == false) {
                    stdout.printf("Error initialising plugin: Plugin init function reported failure.\n");
                    throw new PluginComponentDefLoadError.INIT_ERROR("Plugin init function reported failure: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
                } else {
                    stdout.printf("Initialising plugin... (plugin_component_init).\n");
                }
            } else {
                stdout.printf("Got null plugin_component_init function.\n");
            }
        }
        if (init_pointer == null) {
            stdout.printf("Plugin has no init function (plugin_component_init).\n");
        }

        if (module.symbol("plugin_component_get_def", out get_def_pointer)) {
            if (get_def_pointer != null) {
                get_def_function = (get_def_delegate) get_def_pointer;
            }
        }
        if (get_def_pointer == null) {
            stdout.printf("Error initialising plugin: Could not get component definition function.\n");
            throw new PluginComponentDefLoadError.LIBRARY_NOT_COMPATIBLE("Could not get component definition function: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
        } else {
            pluginComponentDef = get_def_function(this.filename);
            if (pluginComponentDef == null) {
                stdout.printf("Error initialising plugin: Failure getting component definition.\n");
                throw new PluginComponentDefLoadError.INIT_ERROR("Failure getting component definition: \"" + filename + "\": \"" + fullLibraryPath + "\": ");
            }
        }
    }

    public void print_info(string text) {
        stdout.printf("Plugin \"%s\" (\"%s\") Info:\n\t%s\n", name, filename, text);
    }

    public void print_error(string text) {
        stdout.printf("Plugin \"%s\" (\"%s\") Error:\n\t%s\n", name, filename, text);
    }

    private void unload() {
        pluginComponentDef.manager = null;
        pluginComponentDef = null;
    }
}
