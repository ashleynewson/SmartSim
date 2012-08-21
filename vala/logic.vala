/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: logic.vala
 *   
 *   Copyright Ashley Newson 2012
 */



/**
 * Describes the direction a signal is meant to flow.
 */
public enum Flow {
	NONE,
	IN,
	OUT,
	BIDIRECTIONAL
}

/**
 * Describes the direction an object is facing or drawn.
 */
public enum Direction {
	NONE,
	RIGHT,
	DOWN,
	LEFT,
	UP,
	HORIZONTAL,
	VERTICAL,
	DIAGONAL
}


/**
 * Contains the main function. Handles initial load up and contains
 * package information.
 */
public class Core {
	/**
	 * Stores all primitive (built-in) components.
	 */
	public static ComponentDef[] standardComponentDefs;
	
	public static const string programName = "SmartSim";
	public static const string shortVersionString = Config.version;
	public static const string versionString = Config.version + "";
	public static const string copyrightString = "Ashley Newson 2012";
	public static const string licenseName = "Public Package - Freely Distributable";
	public static const string licenseText = 
"""This software, SmartSim, and its corresponding resource files are the
intellectual property of Ashley Newson. This package is released under
the GNU General Public License 3.0 - See the "COPYING" file provided.

This package may be provided with the Gtk and Rsvg Libraries. The
licenses of these libraries are included in the "GTK_COPYING" and
"RSVG_COPYING" files.
""";
	
	
	/**
	 * The beginning point of execution. Starts load up and creates a
	 * single DesignerWindow.
	 */
	public static int main (string[] args) {
		stdout.printf ("%s\n", Core.programName);
		stdout.printf ("\t%s\n", Core.versionString);
		stdout.printf ("Copyright: %s\n", Core.copyrightString);
		stdout.printf ("License: %s\n", Core.licenseName);
		
		stdout.printf ("Loading System...\n");
		
		Gtk.init (ref args);
		
		stdout.printf ("Loading Place-holder Graphic\n");
		Graphic.placeHolder = new Graphic.from_file (Config.resourcesDir + "images/graphics/placeholder");
		
		stdout.printf ("Loading Components\n");
		Core.load_standard_defs ();
		
		new DesignerWindow();
		
		stdout.printf ("Ready\n");
		
		Gtk.main ();
		
		return 0;
	}
	
	/**
	 * Loads all primitive (built-in) components.
	 */
	private static void load_standard_defs () {
		ComponentDef[] standardComponentDefs = {};
		
		try {
			standardComponentDefs += new BufferComponentDef ();
			standardComponentDefs += new AndComponentDef ();
			standardComponentDefs += new OrComponentDef ();
			standardComponentDefs += new XorComponentDef ();
			standardComponentDefs += new TristateComponentDef ();
			standardComponentDefs += new MultiplexerComponentDef ();
			standardComponentDefs += new PeDFlipflopComponentDef ();
			standardComponentDefs += new TFlipflopComponentDef ();
			standardComponentDefs += new MemoryComponentDef ();
			standardComponentDefs += new ConstantComponentDef ();
			standardComponentDefs += new ClockComponentDef ();
			standardComponentDefs += new ToggleComponentDef ();
			standardComponentDefs += new ReaderComponentDef ();
			standardComponentDefs += new BasicSsDisplayComponentDef ();
		} catch (ComponentDefLoadError error) {
			Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
				null,
				Gtk.DialogFlags.MODAL,
				Gtk.MessageType.ERROR,
				Gtk.ButtonsType.OK,
				"There was a fatal error trying to load the built in components:\n%s",
				error.message);
			
			messageDialog.run ();
			messageDialog.destroy ();
			Process.exit (1);
		}
		Core.standardComponentDefs = standardComponentDefs;
	}
	
	/**
	 * Returns //standardComponentDefs//.
	 */
	public static ComponentDef[] get_standard_defs () {
		return standardComponentDefs;
	}
}

