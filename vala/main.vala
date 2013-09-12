/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: main.vala
 *   
 *   Copyright Ashley Newson 2013
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
	public static const string[] authorsStrings = {"Ashley Newson <ashleynewson@smartsim.org.uk>", null};
	public static const string websiteString = "http://www.smartsim.org.uk";
	public static const string shortVersionString = Config.version;
	public static const string versionString = Config.version + "";
	public static const string copyrightString = "Ashley Newson 2013";
	public static const Gtk.License licenseType = Gtk.License.GPL_3_0;
	public static const string licenseName = "Public Package - GNU GPL 3.0 - Freely Distributable";
	public static const string shortLicenseText = 
"""This software, SmartSim, and its corresponding resource files are the
intellectual property of Ashley Newson. This package is released under
the GNU General Public License 3.0. A provided "COPYING" file provides
the full license text.

This package may be provided with the Gtk and Rsvg Libraries. The
licenses of these libraries are included in the "GTK_COPYING" and
"RSVG_COPYING" files.

SmartSim is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public Licence as published by the
Free Software Foundation; either version 3 of the Licence, or (at your
option) any later version.

SmartSim is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licence
for more details.

You should have received a copy of the GNU General Public Licence along
with SmartSim. If not, see:
  http://www.gnu.org/licenses/
""";
	public static string fullLicenseText = "";
	
	
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
		
		Core.fullLicenseText = Core.load_string_from_file ("COPYING");
		
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
	
	private static string load_string_from_file (string filename) {
		FileStream file = FileStream.open (Config.resourcesDir + filename, "r");
		uint8[] data;
		long length;
		
		if (file == null) {
			stderr.printf ("File could not be opened.\n");
			return "Error opening file! Please see the \"" + filename + "\" file.\n";
		}
		
		file.seek (0, FileSeek.END);
		length = file.tell ();
		file.seek (0, FileSeek.SET);
		
		data = new uint8[length+1];
		
		if (length == file.read(data)) {
			data[length] = 0;
			return (string)data;
		} else {
			stderr.printf ("File could not be read.\n");
			return "Error reading file! Please see the \"" + filename + "\" file.\n";
		}
	}
	
	/**
	 * Returns //standardComponentDefs//.
	 */
	public static ComponentDef[] get_standard_defs () {
		return standardComponentDefs;
	}
}

