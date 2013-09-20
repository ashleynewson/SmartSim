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
 *   Filename: propertyitem/propertyitem-string.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class PropertyItemFile : PropertyItem {
	public string filename;
	
	
	public static string get_filename_throw (PropertySet propertySet, string name) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemFile) {
				return (propertyItem as PropertyItemFile).filename;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a file named \"" + name + "\"");
	}
	
	public static void set_filename_throw (PropertySet propertySet, string name, string filename) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemFile) {
				(propertyItem as PropertyItemFile).filename = filename;
				return;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a file named \"" + name + "\"");
	}
	
	public static string get_filename (PropertySet propertySet, string name) {
		try {
			return get_filename_throw (propertySet, name);
		} catch {
			return "";
		}
	}
	
	public static void set_filename (PropertySet propertySet, string name, string data) {
		try {
			set_filename_throw (propertySet, name, data);
		} catch {}
	}
	
	public static void browse_widget (Gtk.Entry stringEntry) {
		Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
			"Select File",
			null,
			Gtk.FileChooserAction.SAVE,
			Gtk.Stock.CANCEL,
			Gtk.ResponseType.CANCEL,
			Gtk.Stock.OK,
			Gtk.ResponseType.ACCEPT);
		
		fileChooser.set_filename (stringEntry.text);
		
		if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
			stringEntry.text = fileChooser.get_filename ();
		}
		
		fileChooser.destroy ();
	}
	
	
	public PropertyItemFile (string name, string description = "", string filename = "") {
		base (name, description);
		this.filename = filename;
	}
	
	public PropertyItemFile.copy (PropertyItemFile source) {
		base (source.name, source.description);
		this.filename = source.filename;
	}
	
/*	public override Gtk.Widget create_widget () {
		Gtk.Entry stringEntry = new Gtk.Entry ();
		stringEntry.text = filename;
		stringEntry.editable = true;
		
		return stringEntry;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.Entry) {
				filename = (propertyWidget as Gtk.Entry).text;
			}
		}
	}*/
	
	public override Gtk.Widget create_widget () {
		Gtk.Box hBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
		
		Gtk.Entry stringEntry = new Gtk.Entry ();
		stringEntry.text = filename;
		stringEntry.editable = true;
		hBox.pack_start (stringEntry, true, true, 1);
		
		Gtk.Button browseButton = new Gtk.Button.with_label ("Browse");
		browseButton.clicked.connect (() => {PropertyItemFile.browse_widget (stringEntry);});
		hBox.pack_start (browseButton, false, true, 1);
		
		return hBox;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.Box) {
				Gtk.Box hBox = (propertyWidget as Gtk.Box);
				List<weak Gtk.Widget> children = hBox.get_children ();
				
				Gtk.Widget stringEntry = children.nth_data(0);
				
				if (stringEntry is Gtk.Entry) {
					filename = (stringEntry as Gtk.Entry).text;
				}
			}
		}
	}
}
